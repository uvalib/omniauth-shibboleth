require 'omniauth'

module OmniAuth
  module Strategies
    class Shibboleth
      include OmniAuth::Strategy

      # Note, while OmniAuth seems to allow any path to be used here
      # devise does not.  This path should be hijacked by an apache
      # module for shibboleth.
      option :callback_path, "/users/auth/shibboleth/callback"

      # Note, while OmniAuth seems to allow any path to be used here
      # devise does not.
      option :request_path, "/users/auth/shibboleth"

      option :fields, %w(cn givenName sn mail physicalDeliveryOffice telephoneNumber)

      # The request phase results in a redirect to a path that is configured to be hijacked by
      # mod rewrite and shibboleth apache module.
      def request_phase
        redirect options.callback_path
      end

      def callback_phase
        log :debug, "Shibboleth Callback env: #{request.env.inspect}"
        raise "Missing header" unless request.env
        eppn = request.env['HTTP_EPPN']
        affiliation = request.env['HTTP_AFFILIATION']
        if (eppn.to_s.include? '@')
            @uid = eppn;
        elsif (affiliation)
          parseAffiliationString(affiliation).each do | address |
              if address.start_with? 'member@'
                @uid = address;
              end
          end
          if (@uid.nil?)
            @uid = "unknown@unknown"
            raise "Missing header EPPN"
          end
        else
          # this is an error... the apache module and rewrite haven't been properly setup.
          log :error, "Headers: #{request.env}"

          raise "Missing header. Shibboleth likely has not been set up properly"
        end
        super
      end

      def uid
        @uid
      end

      def info
        options.fields.inject({}) do |hash, field|
          hash[field] = request.env["HTTP_#{field.upcase}"]
          hash
        end
      end

      extra do
        {
          :affiliations => (parseAffiliationString(request.env['HTTP_AFFILIATION']) | getInferredAffiliations() | parseMemberString(request.env['HTTP_MEMBER']))
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
