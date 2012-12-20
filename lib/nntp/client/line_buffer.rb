require 'zlib'

module NNTP
  class Client
    # Base line buffer class.
    class LineBufferBase # :nodoc:
      def initialize
        @buffer = ''
      end

      # Fill the line buffer with data.
      def fill(s)
        append_buffer(s)
      end

      # Clean up the line buffer.
      def finish
      end

      protected
      def append_buffer(s)
        @buffer += s

        lines = @buffer.split("\r\n")
        return [] if lines.length == 0

        complete_lines = []

        # After @buffer.split("\r\n") is called, it is guaranteed that the
        # elements from 0 to n-2 are complete lines. However, the line n-1
        # needs to be check if it is also complete afterwards.
        (0..lines.length - 2).each do |index|
          complete_lines << lines[index]
        end

        # If the buffer ends with "\r\n", then the last element is also a
        # complete line, so it should be appended to the return list and
        # removed.
        if /\r\n$/ =~ @buffer
          complete_lines << lines[-1]
          @buffer = ''
        else
          @buffer = lines[-1]
        end

        return complete_lines
      end
    end

    # Handles gzip compressed lines from the server.
    class GzipLineBuffer < LineBufferBase # :nodoc:
      def initialize
        super
        @zstream = Zlib::Inflate.new
      end

      def fill(s)
        append_buffer(@zstream.inflate(s))
      end

      def finish
        remaining_data = @zstream.finish

        # Check if there is any data left in the Zlib::Inflate object, and
        # if so, that means there was incomplete data
        if remaining_data && remaining_data.length > 0
          raise IOError, 'Failed to decompress stream'
        end

        @zstream.close
      end
    end

    # Handles plain ASCII lines from the server.
    class AsciiLineBuffer < LineBufferBase # :nodoc:
    end

    # The NNTP::LineBuffer is actually just a factory proxy that constructs
    # a new object derived from NNTP::LineBufferBase depending on the options
    # passed to LineBuffer.new().
    class LineBuffer # :nodoc:
      def self.new(compressed = false)
        if compressed
          return GzipLineBuffer.new
        else
          return AsciiLineBuffer.new
        end
      end
    end
  end
end

