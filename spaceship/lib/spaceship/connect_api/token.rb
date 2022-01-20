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
        api_token ||= self.create(**hash.transform_keys(&:to_sym)) if hash
        api_token ||= self.from_json_file(filepath) if filepath
        return api_token
      end

      def self.from_token(in_house: nil, token_text: nil)
        self.new(in_house: in_house, token_text: token_text)
      end

      def self.from_json_file(filepath)
        json = JSON.parse(File.read(filepath), { symbolize_names: true })

        missing_keys = []
        missing_keys << 'key_id' unless json.key?(:key_id)
        missing_keys << 'issuer_id' unless json.key?(:issuer_id)
        missing_keys << 'key' unless json.key?(:key)

        unless missing_keys.empty?
          raise "App Store Connect API key JSON is missing field(s): #{missing_keys.join(', ')}"
        end

        self.create(**json)
      end

      def self.create(key_id: nil, issuer_id: nil, filepath: nil, key: nil, is_key_content_base64: false, duration: nil, in_house: nil, token_text: nil, **)
        key_id ||= ENV['SPACESHIP_CONNECT_API_KEY_ID']
        issuer_id ||= ENV['SPACESHIP_CONNECT_API_ISSUER_ID']
        filepath ||= ENV['SPACESHIP_CONNECT_API_KEY_FILEPATH']
        duration ||= ENV['SPACESHIP_CONNECT_API_TOKEN_DURATION']
        token_text ||= ENV['SPACESHIP_CONNECT_API_TOKEN_TEXT']

        in_house_env = ENV['SPACESHIP_CONNECT_API_IN_HOUSE']
        in_house ||= !["", "no", "false", "off", "0"].include?(in_house_env) if in_house_env

        if token_text.nil?
          key ||= ENV['SPACESHIP_CONNECT_API_KEY']
          key ||= File.binread(filepath)

          if !key.nil? && is_key_content_base64
            key = Base64.decode64(key)
          end
        end

        self.new(
          key_id: key_id,
          issuer_id: issuer_id,
          key: OpenSSL::PKey::EC.new(key),
          key_raw: key,
          duration: duration,
          in_house: in_house,
          token_text: token_text
        )
      end

      def initialize(key_id: nil, issuer_id: nil, key: nil, key_raw: nil, duration: nil, in_house: nil, token_text: nil)
        @in_house = in_house
        @text = token_text
        @text_direct = !@text.nil?
        if @text_direct
          token_decoded_payload, = JWT.decode(token_text, nil, false, { algorithm: 'ES256' })
          @expiration = Time.at(token_decoded_payload['exp'])
          return
        end
        @key_id = key_id
        @key = key
        @key_raw = key_raw
        @issuer_id = issuer_id
        @duration = duration

        @duration ||= DEFAULT_TOKEN_DURATION
        @duration = @duration.to_i if @duration

        refresh!
      end

      def refresh!
        if @text_direct
          raise "Cannot perform refresh on directly given token; it is perhaps expired; expiration is #{@expiration}"
        end

        @expiration = Time.now + @duration

        header = {
          kid: key_id
        }

        payload = {
          iss: issuer_id,
          exp: @expiration.to_i,
          aud: 'appstoreconnect-v1'
        }

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
