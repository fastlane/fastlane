require 'json'
require 'fastlane_core'

require_relative 'client'

module Supply
  # Sends one Google Play Developer API request and returns Google's JSON response.
  class ApiRunner
    METHODS = %w(GET POST PUT PATCH DELETE).freeze

    def initialize(method:, path:, body: nil, paginate: false, json_key: nil, json_key_data: nil, yes: false)
      @method = method.to_s.upcase
      @path = path.to_s.delete_prefix("/")
      @body = body
      @paginate = paginate
      @json_key = json_key || ENV['SUPPLY_JSON_KEY']
      @json_key_data = json_key_data || ENV['SUPPLY_JSON_KEY_DATA']
      @yes = yes
    end

    # The response as JSON text, or nil when Google sends no body.
    def run
      json = request
      return json && JSON.pretty_generate(json)
    end

    # The response parsed: a Hash, or nil when Google sends no body. Error statuses fail.
    def request
      result = response
      UI.user_error!(self.class.error_message(result)) unless success?(result)
      return result[:body].empty? ? nil : result[:json]
    end

    # { status:, body:, json: }, as github_api returns. Error statuses are returned, not raised.
    def response
      validate!
      body = parse_body
      pages = [send_request(@path, body)]
      while @paginate && success?(pages.last) && (next_path = next_page_path(pages.last[:json]))
        pages << send_request(next_path, nil)
      end
      last = pages.last
      return last unless pages.size > 1 && success?(last)

      merged = merge_pages(pages.map { |page| page[:json] })
      return { status: last[:status], body: merged.to_json, json: merged }
    end

    # Google's error message, or the body when it has none.
    def self.error_message(result)
      return "Google Api Error: #{result[:status]} - #{result[:json].dig('error', 'message') || result[:body]}"
    end

    private

    def validate!
      UI.user_error!("Unsupported method '#{@method}', use one of #{METHODS.join(', ')}") unless METHODS.include?(@method)
      UI.user_error!("A path is required, e.g. /androidpublisher/v3/applications/com.example/reviews") if @path.empty?
      # The credentials go to whatever host the URL names.
      UI.user_error!("Pass a path such as /androidpublisher/v3/applications/com.example/reviews, not a full URL") if @path.include?("://")
      UI.user_error!("--paginate only applies to GET") if @paginate && @method != "GET"
      UI.user_error!("GET takes no --body") if @body && @method == "GET"
      UI.user_error!("DELETE needs --yes to confirm") if @method == "DELETE" && !@yes
    end

    def parse_body
      return nil if @body.nil?
      return @body.to_json if @body.kind_of?(Hash)
      text = @body.start_with?("@") ? File.read(@body[1..]) : @body
      JSON.parse(text)
      return text
    rescue JSON::ParserError => e
      UI.user_error!("--body is not valid JSON: #{e.message}")
    end

    def service
      @service ||= Supply::Client.make_from_config(params: { json_key: @json_key, json_key_data: @json_key_data, timeout: 300 }).client
    end

    # Google's client returns only the body; this command keeps the status too.
    class StatusCommand < Google::Apis::Core::HttpCommand
      attr_reader :status

      def process_response(status, header, body)
        @status = status
        super
      end
    end

    # What BaseService#http does, keeping the status. Error statuses come back as results.
    def send_request(path, body)
      options = Google::Apis::RequestOptions.new(header: { 'Content-Type' => 'application/json' }) if body
      # An empty body keeps the client from form-encoding the query into a POST.
      body ||= "" if %w(POST PUT PATCH).include?(@method)
      command = StatusCommand.new(@method.downcase.to_sym, service.root_url + path, body: body)
      command.options = service.request_options.merge(options)
      text = command.execute(service.client)
      return result(command.status, text)
    rescue Google::Apis::ClientError, Google::Apis::ServerError => e
      return result(e.status_code, e.body)
    end

    def result(status, text)
      text = text.to_s
      json = begin
               JSON.parse(text)
             rescue JSON::ParserError
               nil
             end
      return { status: status, body: text, json: json.kind_of?(Hash) ? json : {} }
    end

    def success?(result)
      result[:status].to_i.between?(200, 299)
    end

    # Older endpoints (reviews, in-app products, users) page with `token` and `tokenPagination`,
    # newer ones with `pageToken` and `nextPageToken`.
    def next_page_path(json)
      return nil unless json.kind_of?(Hash)
      if (token = json["nextPageToken"])
        return with_query(@path, "pageToken", token)
      elsif (token = json.dig("tokenPagination", "nextPageToken"))
        return with_query(@path, "token", token)
      end
      return nil
    end

    def with_query(path, key, value)
      uri = URI.parse(path)
      query = URI.decode_www_form(uri.query.to_s).reject { |k, _| k == key } << [key, value]
      uri.query = URI.encode_www_form(query)
      return uri.to_s
    end

    def merge_pages(pages)
      json = pages.first.dup
      json.each_key do |key|
        next unless json[key].kind_of?(Array)
        json[key] = pages.flat_map { |page| page[key] || [] }
      end
      json.delete("nextPageToken")
      json.delete("tokenPagination")
      return json
    end
  end
end
