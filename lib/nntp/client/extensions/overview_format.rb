module NNTP
  class Client
    module Extensions
      # Parses headers returned from the XOVER command using the OVERVIEW.FMT
      # list.
      class OverviewFormatParser
        # The OVERVIEW.FMT list used to parse the headers.
        attr_reader :overview_fmt

        # Constructs a new OverviewFormatParser object using the provided
        # OVERVIEW.FMT list.
        #
        # === Parameters
        # +overview_fmt+ is the list of headers returned from the OVERVIEW.FMT
        # list to use while parsing headers.
        #
        # :call-seq:
        #   new(overview_fmt) -> new_parser
        def initialize(overview_fmt)
          @overview_fmt = overview_fmt
        end

        # Parses a single header from the server and returns a hash containing
        # the contents.
        #
        # === Parameters
        # +header+ is the raw header represented as a String.
        #
        # +convert+ indicates whether to convert certain values, such as
        # integers or dates to their Ruby native values.
        def parse_header(header, convert = true)
          header_items = header.split("\t")
          header_hash = { id: header_items[0].to_i }

          @overview_fmt.each_with_index do |header, i|
            header_symbol = NNTP::Headers.to_symbol(header.chop)
            header_symbol = header if header_symbol.nil?
            header_hash[header_symbol] = header_items[i + 1]
          end

          return header_hash unless convert

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
end

