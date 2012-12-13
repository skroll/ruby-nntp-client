module NNTP
  class Client
    # XFEATURES
    #
    # Sends the XFEATURES command and a list of features to enable for the
    # \NNTP connection.
    #
    # === Parameteres
    # +features+ can be an array of Strings or just a String, which is the
    # features to enable on the server.
    #
    # :call-seq:
    #   xfeatures(feature)                 -> response
    #   xfeatures([feature1, feature2...]) -> response
    def xfeatures(features)
      features = xfeatures_array(features)
      return unless features.length

      response = long_cmd(XFEATURES_COMMAND)

      features.each do |feature|
        if feature = xfeature_str(feature)
          @protocol.writeline(feature)
        end
      end

      @protocol.writeline(".")
      response = @protocol.read_response
      response
    end

    private
    # :nodoc:
    XFEATURES_COMMAND = 'XFEATURES'

    # :nodoc:
    XFEATURES_SYMBOL_TABLE = {
      compress_gzip: 'COMPRESS GZIP'
    }

    def xfeatures_array(features) # :nodoc:
      features = [features] unless features.is_a? Array
      features = features.map { |x| xfeature_str(x) }
      features.delete(nil)
      return features
    end

    def xfeature_str(feature) # :nodoc:
      return feature if feature.is_a? String
      raise ArgumentError, 'Feature is not a symbol or string' unless feature.is_a? Symbol

      return XFEATURES_SYMBOL_TABLE[feature]
    end
  end
end

