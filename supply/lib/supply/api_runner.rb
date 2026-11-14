require 'json'
require 'fastlane_core'

require_relative 'client'

module Supply
  # Sends one Google Play Developer API request and returns Google's JSON response as text.
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

    def run
      validate!
      body = parse_body
      pages = [request(@path, body)]
      while @paginate && (next_path = next_page_path(pages.last))
        pages << request(next_path, nil)
      end
      return nil if pages.last.nil?

      return JSON.pretty_generate(@paginate ? merge_pages(pages) : pages.first)
    rescue Google::Apis::Error => e
      # Google's answer, not a crash: show it without a stack trace.
      UI.user_error!("Google Api Error: #{e.message} - #{error_message(e)}")
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
      text = @body.start_with?("@") ? File.read(@body[1..]) : @body
      JSON.parse(text)
      return text
    rescue JSON::ParserError => e
      UI.user_error!("--body is not valid JSON: #{e.message}")
    end

    def service
      @service ||= Supply::Client.make_from_config(params: { json_key: @json_key, json_key_data: @json_key_data, timeout: 300 }).client
    end

    def request(path, body)
      options = Google::Apis::RequestOptions.new(header: { 'Content-Type' => 'application/json' }) if body
      # An empty body keeps the client from form-encoding the query into a POST.
      body ||= "" if %w(POST PUT PATCH).include?(@method)
      text = service.http(@method.downcase.to_sym, service.root_url + path, body: body, options: options)
      return nil if text.nil? || text.empty?
      return JSON.parse(text)
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

    def error_message(error)
      parsed = JSON.parse(error.body.to_s)
      return parsed.dig("error", "message") || error.body
    rescue JSON::ParserError
      return error.body
    end
  end
end
