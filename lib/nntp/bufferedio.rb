module NNTP
  # Manages a read buffer for an IO object
  class IOBuffer # :nodoc:
    # :nodoc:
    DEFAULT_BUFFER_SIZE = 1024 * 16

    def initialize(io)
      @io = io
      @buffer = ''
      @read_timeout = 60
      @buffer_size = DEFAULT_BUFFER_SIZE
    end

    attr_reader :io
    attr_accessor :read_timeout

    # Attempt to fill the IOBuffer
    def fill
      begin
        @buffer << @io.read_nonblock(@buffer_size)
      rescue ::IO::WaitReadable
        IO.select([@io], nil, nil, @read_timeout) ? retry : (raise ::Timeout::Error)
      rescue ::IO::WaitWritable
        IO.select(nil, [@io], nil, @read_timeout) ? retry : (raise ::Timeout::Error)
      end
    end

    # Consume bytes from the IOBuffer
    def consume(len)
      return @buffer.slice!(0, len)
    end

    # Number of bytes in the buffer
    def size
      @buffer.size
    end

    def index(i)
      @buffer.index(i)
    end
  end

  class BufferedIO # :nodoc:
    def initialize(io)
      @io = io
      @read_buffer = IOBuffer.new(io)
    end

    def read(len, desg = '', ignore_eof = false)
      read_bytes = 0
      begin
        while read_bytes + @read_buffer.size < len
          dest << (s = @read_buffer.consume(@read_buffer.size))
          read_bytes += s.size
          @read_buffer.fill
        end
        dest << (s = @read_buffer.consume(len - read_bytes))
        read_bytes += s.size
      rescue EOFError
        raise unless ignore_eof
      end
      dest
    end

    def read_all(dest = '')
      read_bytes = 0
      begin
        while true
          dest << (s = @read_buffer.consume(@read_buffer.size))
          read_bytes += s.size
          @read_buffer.fill
        end
      rescue EOFError
        ;
      end
      dest
    end

    def readuntil(terminator, ignore_eof = false)
      begin
        until idx = @read_buffer.index(terminator)
          @read_buffer.fill
        end
        return @read_buffer.consume(idx + terminator.size)
      rescue EOFError
        raise unless ignore_eof
        return @read_buffer.consume(@read_buffer.size)
      end
    end

    def readline(chop = true)
      s = readuntil("\n")
      return chop ? s.chop : s
    end

    def write(str)
      writing { write0 str }
    end

    def writeline(str)
      writing { write0 str + "\r\n" }
    end

    private
    def writing
      @written_bytes = 0
      yield
      bytes = @written_bytes
      @written_bytes = nil
      bytes
    end

    def write0(str)
      len = @io.write(str)
      @written_bytes += len
      len
    end
  end
end

