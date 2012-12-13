module NNTP
  class Client
    # QUIT
    #
    # Sends the QUIT command to terminate the \NNTP session.
    #
    # :call-seq:
    #   quit() -> response
    def quit
      response = short_cmd(QUIT_COMMAND)
      response
    end

    private
    QUIT_COMMAND = 'QUIT' # :nodoc:
  end
end

