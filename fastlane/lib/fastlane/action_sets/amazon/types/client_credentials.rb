module Fastlane::ActionSets::Amazon
  # Describes a token and its metadata; used for authenticating with an Amazon API.
  class ClientCredentials
    # @return [String] The actual access token itself
    attr_reader :access_token
    # @return [String] The scope of the token; for our purposes, this is "appstore::apps:readwrite"
    attr_reader :scope
    # @return [String] The type of credential; this is always "bearer"
    attr_reader :token_type
    # @return [Number] The number of seconds until these credentials expire
    attr_reader :expires_in

    # @param [Hash] json
    def initialize(json)
      @access_token = json['access_token']
      @scope = json['scope']
      @token_type = json['token_type']
      @expires_in = json['expires_in']
    end

    # @param [ClientCredentials] other
    # @return [Boolean]
    def ==(other)
      access_token == other.access_token &&
        scope == other.scope &&
        token_type == other.token_type &&
        expires_in == other.expires_in
    end

    def to_s
      "<Fastlane::ActionSets::Amazon::ClientCredentials:#{object_id} access_token=>\"#{access_token}\">"
    end
  end
end
