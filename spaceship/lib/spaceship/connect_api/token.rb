require 'jwt'
require 'base64'
require 'openssl'

# extract pem from .p8
# openssl pkcs8 -topk8 -outform PEM -in AuthKey.p8 -out key.pem -nocrypt

# compute public key
# openssl ec -in key.pem -pubout -out public_key.pem -aes256

module Spaceship
  class ConnectAPI
    class Token
      # maximum expiration supported by AppStore (20 minutes)
      MAX_TOKEN_DURATION = 1200
      DEFAULT_TOKEN_DURATION = 500

      attr_reader :key_id
      attr_reader :issuer_id
      attr_reader :text
      attr_reader :duration
      attr_reader :expiration

      attr_reader :key_raw

      # Temporary attribute not needed to create the JWT text
      # There is no way to determine if the team associated with this
      # key is for App Store or Enterprise so this is the temporary workaround
      attr_accessor :in_house

      def self.from(hash: nil, filepath: nil)
        # FIXME: Ensure `in_house` value is a boolean.
        api_token ||= self.create(**hash.transform_keys(&:to_sym)) if hash
        api_token ||= self.from_json_file(filepath) if filepath
        return api_token
      end

      def self.from_json_file(filepath)
        json = JSON.parse(File.read(filepath), { symbolize_names: true })

        missing_keys = []
        missing_keys << 'key_id' unless json.key?(:key_id)
        missing_keys << 'key' unless json.key?(:key)

        unless missing_keys.empty?
          raise "App Store Connect API key JSON is missing field(s): #{missing_keys.join(', ')}"
        end

        self.create(**json)
      end

      def self.create(key_id: nil, issuer_id: nil, filepath: nil, key: nil, is_key_content_base64: false, duration: nil, in_house: nil, **)
        key_id ||= ENV['SPACESHIP_CONNECT_API_KEY_ID']
        issuer_id ||= ENV['SPACESHIP_CONNECT_API_ISSUER_ID']
        filepath ||= ENV['SPACESHIP_CONNECT_API_KEY_FILEPATH']
        duration ||= ENV['SPACESHIP_CONNECT_API_TOKEN_DURATION']

        in_house_env = ENV['SPACESHIP_CONNECT_API_IN_HOUSE']
        in_house ||= !["", "no", "false", "off", "0"].include?(in_house_env) if in_house_env

        key ||= ENV['SPACESHIP_CONNECT_API_KEY']
        key ||= File.binread(filepath)

        if !key.nil? && is_key_content_base64
          key = Base64.decode64(key)
        end

        self.new(
          key_id: key_id,
          issuer_id: issuer_id,
          key: OpenSSL::PKey::EC.new(key),
          key_raw: key,
          duration: duration,
          in_house: in_house
        )
      end

      def initialize(key_id: nil, issuer_id: nil, key: nil, key_raw: nil, duration: nil, in_house: nil)
        @key_id = key_id
        @key = key
        @key_raw = key_raw
        @issuer_id = issuer_id
        @duration = duration
        @in_house = in_house

        @duration ||= DEFAULT_TOKEN_DURATION
        @duration = @duration.to_i if @duration

        refresh!
      end

      def refresh!
        now = Time.now
        @expiration = now + @duration

        header = {
          kid: key_id,
          typ: 'JWT'
        }

        payload = {
          # Reduce the issued-at-time in case our time is slighly ahead of Apple's servers, which causes the token to be rejected.
          iat: now.to_i - 60,
          exp: @expiration.to_i,
          aud: @in_house ? 'apple-developer-enterprise-v1' : 'appstoreconnect-v1'
        }
        if issuer_id
          payload[:iss] = issuer_id
        else
          # Consider the key as individual key.
          # https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests#4313913
          payload[:sub] = 'user'
        end

        @text = JWT.encode(payload, @key, 'ES256', header)
      end

      def expired?
        @expiration < Time.now
      end

      def write_key_to_file(path)
        File.open(path, 'w') { |f| f.write(@key_raw) }
      end
    end
  end
end
