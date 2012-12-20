require 'socket'
require 'zlib'
require 'timeout'
require 'nntp/client/version'
require 'nntp/client/errors'
require 'nntp/client/headers'
require 'nntp/client/protocol'
require 'nntp/client/commands'

module NNTP
  # \Client interface to an \NNTP server.
  class Client
    # The hostname of the \NNTP server.
    attr_reader :hostname

    # The port of the \NNTP server.
    attr_reader :port

    # The timeout used when connecting to the \NNTP server.
    attr_reader :open_timeout

    # Create a new NNTP::Client object.
    #
    # :call-seq:
    #   NNTP::Client.new(hostname)                -> client
    #   NNTP::Client.new(hostname, port)          -> client
    #   NNTP::Client.new(hostname, options)       -> client
    #   NNTP::Client.new(hostname, port, options) -> client
    #
    def initialize(hostname, port = nil, options = {})
      if port.kind_of? Hash and options.size == 0
        options = port
        port = nil
      end

      unless (evil = options.keys - VALID_OPTIONS).empty?
        raise ArgumentError, "#{evil.inspect} are not valid options for " \
                             'Client.new'
      end

      self.hostname     = hostname
      self.port         = port || DEFAULT_PORT
      self.open_timeout = options[:open_timeout] || DEFAULT_OPEN_TIMEOUT

      @socket = nil
      @started = false
    end

    # Creates a new NNTP::Client object and connects to the server.
    #
    # This method is equivalent to:
    #   NNTP::Client.new(hostname, port, options).start()
    #
    # === Example
    #
    #     NNTP::Client.start('your.nntp.server') do |nntp|
    #       puts nntp.capabilities
    #     end
    #
    # === Block Usage
    #
    # If called with a block, the newly opened NNTP::Client object is yielded
    # to the block, and automatically closed when the block finishes. If
    # called without a block, the newly opened NNTP::Client object is
    # returned to the caller, and it is the caller's responsibility to close
    # it when finished.
    #
    # === Parameters
    #
    # +hostname+ is the hostname of the \NTTP server.
    #
    # +port+ is the port to connect to; it defaults to port 119.
    #
    # === Errors
    # 
    # This method may raise:
    # 
    # * NNTP::Client::AuthenticationError
    # * NNTP::Client::FatalError
    # * NNTP::Client::ServerBusy
    # * NNTP::Client::SyntaxError
    # * NNTP::Client::UnknownError
    # * IOError
    # * TimeoutError
    #
    # :call-seq:
    #   NNTP::Client.start(hostname)                               -> client
    #   NNTP::Client.start(hostname, port)                         -> client
    #   NNTP::Client.start(hostname, options)                      -> client
    #   NNTP::Client.start(hostname, port, options)                -> client
    #   NNTP::Client.start(hostname) { |nntp| ... }                -> nil
    #   NNTP::Client.start(hostname, port) { |nntp| ... }          -> nil
    #   NNTP::Client.start(hostname, options) { |nntp| ... }       -> nil
    #   NNTP::Client.start(hostname, port, options) { |nntp| ... } -> nil
    def self.start(hostname, port = nil, options = {}, &block)
      new(hostname, port, options).start(&block)
    end

    # Opens a TCP connection and starts the \NNTP client session.
    #
    # === Example
    #
    #     NNTP::Client.new('your.nntp.server').start do |nntp|
    #       puts nntp.capabilities
    #     end
    #
    # === Block Usage
    #
    # When this method is called with a block, the newly-started Client
    # object is yielded to the block, and automatically closed after the
    # block call finishes. Otherwise, it's the caller's responsibility to
    # close the session when finished.
    #
    # === Errors
    # 
    # This method may raise:
    # 
    # * NNTP::Client::AuthenticationError
    # * NNTP::Client::FatalError
    # * NNTP::Client::ServerBusy
    # * NNTP::Client::SyntaxError
    # * NNTP::Client::UnknownError
    # * IOError
    # * TimeoutError

    def start
      if block_given?
        begin
          do_start
          return yield(self)
        ensure
          do_finish
        end
      else
        do_start
        return self
      end
    end

    protected
    VALID_OPTIONS = [:open_timeout] # :nodoc:
    DEFAULT_PORT = 119 # :nodoc:
    DEFAULT_OPEN_TIMEOUT = 30 # :nodoc:

    attr_writer :hostname, :port, :open_timeout # :nodoc:

    # +true+ if the \NNTP session has been started.
    def started? # :nodoc:
      @started
    end

    # Execute a command on the server and parse the response.
    def short_cmd(fmt, *args) # :nodoc:
      return @protocol.check_response(@protocol.get_response(fmt, *args))
    end

    # Execute a command on the server that is a multi-line command, and
    # parse the response.
    def long_cmd(fmt, *args) # :nodoc:
      return @protocol.check_response(@protocol.get_response(fmt, *args), true)
    end

    # Start the session
    def do_start # :nodoc:
      raise IOError, 'NNTP session already started' if started?

      @socket = timeout(self.open_timeout) do
        TCPSocket.open(self.hostname, self.port)
      end

      @protocol = ::NNTP::Client::Protocol.new(@socket)

      @protocol.read_response
      @started = true
    ensure
      @socket.close if not started? and @socket and not @socket.closed?
    end

    # Finish the session
    def do_finish # :nodoc:
      quit if @socket and not @socket.closed?
    ensure
      @started = false
      @socket.close if @socket and not @socket.closed?
      @socket = nil
      @protocol = nil
    end
  end
end

