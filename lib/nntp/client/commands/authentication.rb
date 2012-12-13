module NNTP
  class Client
    # AUTHINFO USER <user>
    # AUTHINFO PASS <secret>
    #
    # Authenticates the user with the original implementation of \NNTP
    # authentication.
    #
    # === Parameters
    # +user+ is the name of the user.
    #
    # +secret+ is the password for the user.
    def auth_original(user, secret)
      response = @protocol.critical {
        long_cmd(AUTHINFO_ORIGINAL_COMMAND_USER, user)
        short_cmd(AUTHINFO_ORIGINAL_COMMAND_PASS, secret)
      }
      return response
    end

    # AUTHINFO SIMPLE
    # <user> <secret>
    #
    # Authenticates the user wtih the simple implementation of \NNTP
    # authentication.
    #
    # === Parameters
    # +user+ is the name of the user.
    #
    # +secret+ is the password for the user.
    def auth_simple(user, secret)
      response = @protocol.critical {
        long_cmd(AUTHINFO_SIMPLE_COMMAND_1)
        short_cmd(AUTHINFO_SIMPLE_COMMAND_2, user, secret)
      }
      return response
    end

    private
    AUTHINFO_ORIGINAL_COMMAND_USER = "AUTHINFO USER %s" # :nodoc:
    AUTHINFO_ORIGINAL_COMMAND_PASS = "AUTHINFO PASS %s" # :nodoc:

    AUTHINFO_SIMPLE_COMMAND_1 = 'AUTHINFO SIMPLE' # :nodoc:
    AUTHINFO_SIMPLE_COMMAND_2 = "%s %s" # :nodoc:
  end
end

