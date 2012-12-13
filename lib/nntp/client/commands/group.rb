module NNTP
  class Client
    # GROUP
    #
    # Changes the currently selected newsgroup.
    #
    # === Example
    #     NNTP::Client.start('your.nntp.server') do |nntp|
    #       response = nntp.group('comp.lang.ruby')
    #     end
    #
    # === Parameters
    # +newsgroup+ is the newsgroup to change to.
    #
    # === Errors
    # 
    # This method may raise:
    # 
    # * IOError
    # * TimeoutError
    def group(newsgroup)
      response = short_cmd(GROUP_COMMAND, newsgroup)
      m = response[:message].chop.match(/(^[\d]*) ([\d]*) ([\d]*) (.*)/i).captures
      return response, { count: m[0].to_i, low: m[1].to_i, high: m[2].to_i, group: m[3] }
    end

    private
    GROUP_COMMAND = "GROUP %s" # :nodoc:
  end
end

