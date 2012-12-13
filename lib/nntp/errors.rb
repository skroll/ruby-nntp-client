module NNTP
  class Error < StandardError # :nodoc:
  end

  class ProtocolError < Error # :nodoc:
  end

  class UnknownError < ProtocolError # :nodoc:
  end

  class AuthenticationError < ProtocolError # :nodoc:
  end

  class ServerBusy < ProtocolError # :nodoc:
  end

  class SyntaxError < ProtocolError # :nodoc:
  end

  class FatalError < ProtocolError # :nodoc:
  end
end

