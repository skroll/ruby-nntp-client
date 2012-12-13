module NNTP
  # Contains constants and methods for use in parsing headers for articles.
  module Headers
    # Mandatory Headers

    # \Date of an article.
    DATE       = 'Date'

    # Author of an article.
    FROM       = 'From'

    # Unique message identifer.
    MESSAGE_ID = 'Message-ID'

    # Newsgroups that the article is posted to.
    NEWSGROUPS = 'Newsgroups'

    # Route taken by an article.
    PATH       = 'Path'

    # Subject of an article.
    SUBJECT    = 'Subject'


    # Optional Headers

    # Entities approving an article.
    APPROVED       = 'Approved'

    # Indication of the poster's intent regarding preservation of an article.
    ARCHIVE        = 'Archive'

    # Marks article as a control message.
    CONTROL        = 'Control'

    # Specifies geographic or organizational limits on an article's
    # propagation.
    DISTRIBUTION   = 'Distribution'

    # The date and time that an article is no longer relevant.
    EXPIRES        = 'Expires'

    # Specifies which newsgroup(s) the poster has requested that followups
    # are to be posted.
    FOLLOWUP_TO    = 'Followup-To'

    # The date and time the article was injected into the network.
    INJECTION_DATE = 'Injection-Date'

    # How the article was injected into the network.
    INJECTION_INFO = 'Injection-Info'

    # Identifies the article poster's organization.
    ORGANIZATION   = 'Organization'

    # Message's that are referenced in the article.
    REFERENCES     = 'References'

    # Short phrase summarizing the article's content.
    SUMMARY        = 'Summary'

    # Message identifier that this article supersedes.
    SUPERSEDES     = 'Supersedes'

    # The user agent used to generate the article.
    USER_AGENT     = 'User-Agent'

    # Where the article was filed by the news server.
    XREF           = 'Xref'

    # Number of bytes of the article.
    BYTES          = 'Bytes'

    # Number of liens in the article.
    LINES          = 'Lines'

    # List of mandatory headers for an article.
    MANDATORY = [DATE, FROM, MESSAGE_ID, NEWSGROUPS, PATH, SUBJECT]

    # List of optional headers for an article.
    OPTIONAL = [APPROVED, ARCHIVE, CONTROL, DISTRIBUTION, EXPIRES,
      FOLLOWUP_TO, INJECTION_DATE, INJECTION_INFO, ORGANIZATION, REFERENCES,
      SUMMARY, SUPERSEDES, USER_AGENT, XREF, BYTES, LINES]

    class << self
      # Convert a header string to a Ruby symbol.
      def to_symbol(header)
        TO_SYM_TABLE[header]
      end

      # Convert a Ruby symbol to a header string.
      def from_symbol(header)
        FROM_SYM_TABLE[header]
      end
    end

    private
    TO_SYM_TABLE = {}
    FROM_SYM_TABLE = {}

    (MANDATORY + OPTIONAL).each do |header|
      header_symbol = header.sub(/-/, '_').sub(/:/, '_').downcase.to_sym
      TO_SYM_TABLE[header] = header_symbol
      FROM_SYM_TABLE[header_symbol] = header
    end
  end
end

module NNTP
  module Headers
    # Contains helper methods to parsing date headers.
    module Date
      class << self
        # Parses a date/time string from a header and converts it into a
        # Ruby DateTime object.
        def parse(s)
          DateTime.rfc2822(s)
        end
      end
    end
  end
end


