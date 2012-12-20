require 'buffered_io'
require 'nntp/client/line_buffer'

# Extend the String class to add some functionality to simplify the logic
# in NNTP::Protocol.
class String # :nodoc:
  NNTP_TERMINATOR = ".\r\n"

  # Returns if the String object is just a terminator and nothing else.
  def is_nntp_terminator?
    self == NNTP::Client::Protocol::TERMINATOR
  end

  # Returns if the String object ends with a terminator.
  def has_nntp_terminator?
    self[-3..-1] == NNTP::Client::Protocol::TERMINATOR
  end

  # Returns a copy of the String object with the NNTP terminator stripped
  # off.
  def strip_nntp_terminator
    self[0..-4]
  end
end

module NNTP
  class Client
    # Handles low-level communication with an \NNTP server by manipulating an
    # underlying TCPSocket object. All communication with an \NNTP server
    # should occur through this class, never with the TCPSocket itself.
    class Protocol
      # The terminator used when returning a data list from the NNTP server.
      TERMINATOR = ".\r\n" # :nodoc:

      # Creates a new NNTP::Protocol object that manipulates a TCPSocket
      # object.
      #
      # :call-seq:
      #   NNTP::Protocol.new(socket) -> protocol
      #
      def initialize(socket)
        @io = ::BufferedIO::IOBuffer.new(socket)
        @compressed = false
      end

      # Execute a command on the server and then read the response. The
      # response should be passed to check_response() to parse the error code
      # and raise any appropriate exceptions.
      def get_response(fmt, *args)
        writeline(fmt, *args)
        recv_response
      end

      # Read a response from the server without executing a command. This is
      # used in situations where the \NNTP server sends a response message
      # that did not immediately follow a command. For example, after sending
      # the XFEATURES command, a list of commands are set, terminated by a line
      # containing only ".", which the \NNTP server then responds with an error
      # code and message.
      def read_response(allow_continue = false)
        check_response(recv_response, allow_continue)
      end

      # Read a list of lines from the \NNTP server. This is used when the
      # \NNTP server is sending list data, such as a list of newsgroups or
      # message headers. This method automatically strips the terminator from
      # the list and does not return it.
      def readlines
        line_buffer = ::NNTP::Client::LineBuffer.new(@compressed)

        while true
          line = @io.readline(false)

          if line.has_nntp_terminator?
            unless line.is_nntp_terminator?
              line_buffer.fill(line.strip_nntp_terminator).each { |l| yield l }
            end
            break
          end

          line_buffer.fill(line).each { |l| yield l }
        end

        line_buffer.finish
      end

      # Writes raw data to the \NNTP server. This is used in situations where
      # data needs to be written, but it will not be immediately responded to
      # with an error code and message.
      def writeline(fmt, *args)
        @io.writeline sprintf(fmt, *args)
      end

      # Parse the response from the server and raise any exceptions that may
      # have occured based on the error code.
      def check_response(response, allow_continue = false)
        stat, message = split_response(response)
        stat_i = stat.to_i

        # If the response contains the string "COMPRESS=GZIP" then the
        # following payload will be compressed using gzip.
        @compressed = /COMPRESS=GZIP/.match(message) ? true : false

        response = make_response_hash(stat_i, message)
        return response if /\A1/ === stat
        return response if /\A2/ === stat
        return response if allow_continue and /\A[35]/ === stat
        exception = case stat
          when /\A48/  then AuthenticationError
          when /\A4/   then ServerBusy
          when /\A50/  then SyntaxError
          when /\A55/  then FatalError
        else
          UnknownError
        end
        raise exception, response
      end

      # Define a critical section that should be executed by the NNTP::Protocol
      # object. This is used in cases where an entire series of commands need
      # to be executed, and if any fail, then to stop running. This simplifies
      # code in NNTP::Client, so that multi-line commands do not need to be
      # split up and have their individual error codes checked.
      #
      # === Example
      #
      #     response = @protocol.critical {
      #       @protocol.check_response(@protocol.get_response("AUTHINFO USER user@domain.com"), true)
      #       @protocol.check_response(@protocol.get_response("AUTHINFO PASS password"), false)
      #     }
      #
      # :call-seq:
      #   critical { ... }
      def critical()
        @error_occured = false
        return '200 dummy reply code' if @error_occured
        begin
          return yield()
        rescue Exception
          @error_occured = true
          raise
        end
      end

      protected
      # Create a resposne hash object from an \NNTP error code and message.
      def make_response_hash(code, message) # :nodoc:
        { code: code, message: message.chop }
      end

      # Read responses from the \NNTP server.
      def recv_response # :nodoc:
        stat = ''
        while true
          line = @io.readline(false)
          stat << line
          break unless line[3] == ?-
        end
        stat
      end

      RESPONSE_SPLIT_REGEX = /(^[\d]{3}) (.*)/i #:nodoc:

      # Split the response into the error code and message.
      def split_response(response) # :nodoc:
        raise IOError, 'Bad response from server' if response.nil?
        c = response.match(RESPONSE_SPLIT_REGEX).captures
        raise IOError, 'Failed to parse server response' if c.nil? or c.length != 2
        return c[0], c[1]
      end
    end
  end
end

