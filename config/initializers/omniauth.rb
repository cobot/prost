module OmniAuth
  module Strategies
    class Cobot < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => Prost::Config.cobot_site,
        :authorize_url => Prost::Config.cobot_site + '/oauth2/authorize',
        :token_url => Prost::Config.cobot_site + '/oauth2/access_token'
      }

      def request_phase
        super
      end

      uid { raw_info['id'] }

      info do
        {
          'email' => raw_info['email'],
          'picture' => raw_info['picture']
        }
      end

      extra do
        {:raw_info => raw_info}
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('/api/user').parsed
      end
    end
  end
end

OmniAuth.config.add_camelization 'cobot', 'Cobot'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cobot, Prost::Config.client_id, Prost::Config.client_secret, scope: 'read write'
end
