require 'json'
require 'credentials_manager/appfile_config'
require 'fastlane_core/ui/ui'

require_relative 'connect_api'
require_relative 'connect_api/client'

module Spaceship
  # Sends one App Store Connect API request and returns Apple's JSON response.
  class ApiRunner
    METHODS = %w(GET POST PATCH DELETE).freeze

    def initialize(method:, path:, body: nil, paginate: false, api_key_path: nil, token: nil, username: nil, yes: false)
      @method = method.to_s.upcase
      @path = path.to_s.delete_prefix("/")
      @body = body
      @paginate = paginate
      @api_key_path = api_key_path
      @token = token
      @username = username
      @yes = yes
    end

    # The response as JSON text, or nil when Apple sends no body.
    def run
      json = request
      return json && JSON.pretty_generate(json)
    end

    # The response parsed: a Hash, or nil when Apple sends no body.
    def request
      validate!
      body = parse_body
      response = case @method
                 when "GET" then client.get(@path)
                 when "POST" then client.post(@path, body)
                 when "PATCH" then client.patch(@path, body)
                 when "DELETE" then client.delete(@path, nil, body)
                 end
      return nil if response.nil?

      return @paginate ? merge_pages(response.all_pages) : response.body
    rescue Spaceship::UnexpectedResponse => e
      # Apple's answer, not a crash: show it without a stack trace.
      FastlaneCore::UI.user_error!(e.message)
    end

    private

    def validate!
      FastlaneCore::UI.user_error!("Unsupported method '#{@method}', use one of #{METHODS.join(', ')}") unless METHODS.include?(@method)
      FastlaneCore::UI.user_error!("A path is required, e.g. /v1/apps") if @path.empty?
      # The credentials go to whatever host the URL names.
      FastlaneCore::UI.user_error!("Pass a path such as /v1/apps, not a full URL") if @path.include?("://")
      FastlaneCore::UI.user_error!("--paginate only applies to GET") if @paginate && @method != "GET"
      FastlaneCore::UI.user_error!("GET takes no --body") if @body && @method == "GET"
      FastlaneCore::UI.user_error!("DELETE needs --yes to confirm") if @method == "DELETE" && !@yes
    end

    def parse_body
      return nil if @body.nil?
      return @body if @body.kind_of?(Hash)
      text = @body.start_with?("@") ? File.read(@body[1..]) : @body
      return JSON.parse(text)
    rescue JSON::ParserError => e
      FastlaneCore::UI.user_error!("--body is not valid JSON: #{e.message}")
    end

    def client
      @client ||= begin
        token = @token
        token ||= Spaceship::ConnectAPI::Token.from(filepath: @api_key_path) if @api_key_path
        token ||= Spaceship::ConnectAPI::Token.create if ENV['SPACESHIP_CONNECT_API_KEY_ID']
        # Without a key, reuse a session or token set earlier (e.g. in a lane), else log in.
        connect_api = token ? Spaceship::ConnectAPI::Client.new(token: token) : (Spaceship::ConnectAPI.client || login)
        connect_api.tunes_request_client
      end
    end

    # Login messages and prompts go to stderr so stdout holds only the response.
    def login
      username = @username || CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
      stdout = $stdout
      $stdout = $stderr
      username ||= FastlaneCore::UI.input("Apple ID: ")
      return Spaceship::ConnectAPI::Client.login(username, use_portal: false)
    ensure
      $stdout = stdout
    end

    def merge_pages(pages)
      json = pages.first.body.dup
      return json unless json["data"].kind_of?(Array)

      json["data"] = pages.flat_map { |page| page.body["data"] || [] }
      included = pages.flat_map { |page| page.body["included"] || [] }.uniq { |resource| [resource["type"], resource["id"]] }
      json["included"] = included unless included.empty?
      json["links"] = pages.last.body["links"] if pages.last.body["links"]
      return json
    end
  end
end
