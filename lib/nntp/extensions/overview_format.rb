module NNTP
  module Extensions
    class OverviewFormatParser
      def initialize(overview_fmt)
        @overview_fmt = overview_fmt
      end

      def parse_header(header)
        header_items = header.split("\t")
        header_hash = { message_id: header_items[0].to_i }

        @overview_fmt.each_with_index do |header, i|
          header_symbol = NNTP::Headers.to_symbol(header.chop)
          header_symbol = header if header_symbol.nil?
          header_hash[header_symbol] = header_items[i + 1]
        end

        header_hash
      end
    end
  end
end

