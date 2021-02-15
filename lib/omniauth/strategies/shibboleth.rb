require 'omniauth'
require 'omniauth/strategy'

module OmniAuth
  module Strategies
    class Shibboleth
      include OmniAuth::Strategy

      class MissingHeader < StandardError; end

      # Note, while OmniAuth seems to allow any path to be used here
      # devise does not.  This path should be hijacked by an apache
      # module for shibboleth.
      option :callback_path, "/users/auth/shibboleth/callback"

      # Note, while OmniAuth seems to allow any path to be used here
      # devise does not.
      option :request_path, "/users/auth/shibboleth"

      # The request phase results in a redirect to a path that is configured to be hijacked by
      # mod rewrite and shibboleth apache module.
      def request_phase
        redirect options.callback_path
      end

      def callback_phase
        log :info, "Shibboleth Callback"
        if (request.headers && request.headers['eppn'])
            @uid = request.headers['eppn'];
        elsif (request.headers && request.headers['affiliation'])
          parseAffiliationString(request.headers['affiliation']).each do | address |
              if address.start_with? 'member@'
                @uid = address;
              end
          end
          if (@uid.nil?)
            @uid = "unknown@unknown"
          end
        else
          # this is an error... the apache module and rewrite haven't been properly setup.
          log :error, "Headers: #{request.headers}"

          raise MissingHeader.new
        end
        super
      end

      def uid
        @uid
      end

      extra do
        {
          :affiliations => (parseAffiliationString(request.headers['affiliation']) | getInferredAffiliations() | parseMemberString(request.headers['member']))
        }
      end

      def parseAffiliationString(affiliation)
        return [] unless affiliation.respond_to? :split
         affiliation.split(/;/)
      end

      def parseMemberString(members)
        return [] unless members.respond_to? :split
        members.split(/;/)
      end

      def getInferredAffiliations()
        return [] unless @uid.respond_to? :gsub
        [ @uid.gsub(/.+@/, "member@") ]
      end

    end
  end
end
