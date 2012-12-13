module NNTP
  class Client
    # LIST
    #
    # Sends the LIST command to the server and returns the specified list.
    #
    # === Block Usage
    # If the method is called with a block, then the list results will be
    # yielded to the block.
    #
    # === Parameters
    # +list_type+ is the type of list to retrieve.
    #
    # :call-seq:
    #   list(list_type) -> response, array
    #   list(list_type) { |list_item| } -> response

    def list(list_type)
      return if (list_type = list_type_str(list_type)).nil?

      response = long_cmd(LIST_COMMAND, list_type)
      list_items = []

      @protocol.readlines do |list_item|
        yield list_item if block_given?
        list_items << list_item
      end

      return response, list_items unless block_given?
      return response
    end

    private
    LIST_COMMAND = "LIST %s" # :nodoc:

    # :nodoc:
    LIST_TYPE_SYMBOL_TABLE = {
      overview_fmt: 'OVERVIEW.FMT',
      active:       'ACTIVE',
      active_times: 'ACTIVE.TIMES',
      newsgroups:   'NEWSGROUPS',
    }

    def list_type_str(list_type) # :nodoc:
      return list_type if list_type.is_a? String

      return LIST_TYPE_SYMBOL_TABLE[list_type]
    end
  end
end

