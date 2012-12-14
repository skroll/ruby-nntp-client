module NNTP
  module Extensions
    class OverviewFormatParser
      attr_reader :overview_fmt

      def initialize(overview_fmt)
        @overview_fmt = overview_fmt
      end

      def parse_header(header)
        header_items = header.split("\t")
        header_hash = { id: header_items[0].to_i }

        @overview_fmt.each_with_index do |header, i|
          header_symbol = NNTP::Headers.to_symbol(header.chop)
          header_symbol = header if header_symbol.nil?
          header_hash[header_symbol] = header_items[i + 1]
        end

        if header_hash.has_key?(:date)
          header_hash[:date] = Headers::Date.parse(header_hash[:date])
        end

        if header_hash.has_key?(:bytes)
          header_hash[:bytes] = header_hash[:bytes].to_i
        end

        if header_hash.has_key?(:lines)
          header_hash[:lines] = header_hash[:lines].to_i
        end

        header_hash
      end
    end
  end
end

