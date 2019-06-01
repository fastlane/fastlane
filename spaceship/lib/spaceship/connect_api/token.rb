require 'jwt'
require 'openssl'

# extract pem from .p8
# openssl pkcs8 -topk8 -outform PEM -in AuthKey.p8 -out key.pem -nocrypt

# compute public key
# openssl ec -in key.pem -pubout -out public_key.pem -aes256

module Spaceship
  module ConnectAPI
    class Token
      # maximum expiration supported by AppStore (20 minutes)
      MAX_TOKEN_DURATION = 1200

      attr_reader :key_id
      attr_reader :issuer_id
      attr_reader :text

      def initialize(key_id: nil, issuer_id: nil, key: nil)
        @expiration = Time.now + MAX_TOKEN_DURATION
        @key_id = key_id
        @key = key
        @issuer_id = issuer_id

        header = {
          kid: key_id
        }

        payload = {
          iss: issuer_id,
          exp: @expiration.to_i,
          aud: 'appstoreconnect-v1'
        }

        @text = JWT.encode(payload, key, 'ES256', header)
      end

      def expired?
        @expiration < Time.now
      end
    end
  end
end
