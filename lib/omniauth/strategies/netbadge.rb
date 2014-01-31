require 'omniauth'
require 'omniauth/strategy'

module OmniAuth
  module Strategies
    class Netbadge
      include OmniAuth::Strategy

      class MissingHeader < StandardError; end

      # Note, while OmniAuth seems to allow any path to be used here
      # devise does not.  This path should be hijacked by an apache
      # module for pubcookie.
      option :callback_path, "/users/auth/netbadge/callback"

      # Note, while OmniAuth seems to allow any path to be used here
      # devise does not.
      option :request_path, "/users/auth/netbadge"

      # The request phase results in a redirect to a path that is configured to be hijacked by
      # mod rewrite and pubcookie apache module.
      def request_phase
        redirect options.callback_path
      end

      def callback_phase
        log :info, "Netbadge Callback"
        if (request.env && request.env['REMOTE_USER'])
          @uid = request.env['REMOTE_USER']
          super
        else
          # this is an error... the apache module and rewrite haven't been properly setup.
          raise MissingHeader.new
        end
      end

      def uid
        @uid
      end

    end
  end
end