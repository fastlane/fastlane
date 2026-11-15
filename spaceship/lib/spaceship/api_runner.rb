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

    # The response parsed: a Hash, or nil when Apple sends no body. Error statuses fail.
    def request
      result = response
      FastlaneCore::UI.user_error!(self.class.error_message(result)) unless result[:status].between?(200, 299)
      return result[:body].empty? ? nil : result[:json]
    end

    # { status:, body:, json: }, as github_api returns. Error statuses are returned, except 401 and 403, which spaceship raises.
    def response
      validate!
      body = parse_body
      pages = [client.raw_request(@method.downcase.to_sym, @path, body)]
      while @paginate && success?(pages.last) && pages.last.body.kind_of?(Hash) && (next_url = pages.last.body.dig("links", "next"))
        pages << client.raw_request(:get, next_url)
      end
      last = pages.last
      return result(last.status, merge_pages(pages.map(&:body))) if @paginate && success?(last)
      return result(last.status, last.body)
    end

    # Apple's error titles and details, one per line.
    def self.error_message(result)
      errors = result[:json]["errors"]
      return "App Store Connect responded with #{result[:status]}: #{result[:body]}" unless errors.kind_of?(Array)
      return errors.map { |error| [error["title"], error["detail"]].compact.join(" - ") }.join("\n")
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

    def success?(raw)
      raw.status.between?(200, 299)
    end

    def result(status, body)
      return { status: status, body: body.to_json, json: body } if body.kind_of?(Hash)
      text = body.to_s
      json = begin
               JSON.parse(text)
             rescue JSON::ParserError
               nil
             end
      return { status: status, body: text, json: json.kind_of?(Hash) ? json : {} }
    end

    def merge_pages(bodies)
      json = bodies.first.dup
      return json unless json["data"].kind_of?(Array)

      json["data"] = bodies.flat_map { |body| body["data"] || [] }
      included = bodies.flat_map { |body| body["included"] || [] }.uniq { |resource| [resource["type"], resource["id"]] }
      json["included"] = included unless included.empty?
      json["links"] = bodies.last["links"] if bodies.last["links"]
      return json
    end
  end
end
