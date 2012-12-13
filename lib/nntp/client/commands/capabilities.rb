module NNTP
  class Client
    # CAPABILITIES
    #
    # Sends the CAPABILITIES command to the server and returns the list.
    #
    # === Block Usage
    # If the method is called with a block, then the capabilities will be
    # yielded to the block.
    #
    # :call-seq:
    #   capabilities() -> response, array
    #   capabilities() { |capability| } -> response
    def capabilities
      response = short_cmd(CAPABILITIES_COMMAND)
      capability_list = []

      @protocol.readlines do |capability|
        yield capability if block_given?
        capability_list << capability unless block_given?
      end

      return response, capability_list unless block_given?
      return response
    end

    private
    CAPABILITIES_COMMAND = 'CAPABILITIES' # :nodoc:
  end
end

