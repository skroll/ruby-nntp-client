module NNTP
  class Client
    # XOVER
    #
    # Sends the XOVER command to the server and returns the list of headers
    # for a specified range.
    #
    # === Block Usage
    # If the method is called with a block, then the headers will be yielded
    # to the block.
    #
    # === Parameters
    # +first+ is the ID of the first header in the range.
    #
    # +last+ is the ID of the last header in the range. If set to +nil+, then
    # the range extends to the last header for the group.
    #
    # :call-seq:
    #   xover(first)                        -> response, array
    #   xover(first, last)                  -> response, array
    #   xover(first) { |header| ... }       -> response
    #   xover(first, last) { |header| ... } -> response

    def xover(first, last = nil)
      response = short_cmd(XOVER_COMMAND, make_range_str(first, last))

      header_list = []

      @protocol.readlines do |header|
        if block_given?
          yield header
        else
          header_list << header
        end
      end

      return response if block_given?
      return response, header_list
    end

    private
    # :nodoc:
    XOVER_COMMAND = "XOVER %s"

    def make_range_str(first, last) # :nodoc:
      "#{first}-#{last}"
    end
  end
end

