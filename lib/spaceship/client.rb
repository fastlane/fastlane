require 'faraday' # HTTP Client
require 'logger'
require 'faraday_middleware'
require 'spaceship/ui'
require 'spaceship/helper/plist_middleware'
require 'spaceship/helper/net_http_generic_request'


if ENV["DEBUG"]
  require 'openssl'
  # this has to be on top of this file, since the value can't be changed later
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

module Spaceship
  class Client
    PROTOCOL_VERSION = "QH65B2"

    attr_reader :client
    attr_accessor :cookie

    # The logger in which all requests are logged
    # /tmp/spaceship[time].log by default
    attr_accessor :logger

    # Invalid user credentials were provided
    class InvalidUserCredentialsError < StandardError; end

    # Raised when no user credentials were passed at all
    class NoUserCredentialsError < StandardError; end


    class UnexpectedResponse < StandardError; end

    # Authenticates with Apple's web services. This method has to be called once
    # to generate a valid session. The session will automatically be used from then
    # on.
    #
    # This method will automatically use the username from the Appfile (if available)
    # and fetch the password from the Keychain (if available)
    #
    # @param user (String) (optional): The username (usually the email address)
    # @param password (String) (optional): The password
    #
    # @raise InvalidUserCredentialsError: raised if authentication failed
    #
    # @return (Spaceship::Client) The client the login method was called for
    def self.login(user = nil, password = nil)
      instance = self.new
      if instance.login(user, password)
        instance
      else
        raise InvalidUserCredentialsError.new
      end
    end

    def self.hostname
      raise "You must implemented self.hostname"
    end

    def initialize
      @client = Faraday.new(self.class.hostname) do |c|
        c.response :json, content_type: /\bjson$/
        c.response :xml, content_type: /\bxml$/
        c.response :plist, content_type: /\bplist$/
        c.adapter Faraday.default_adapter

        if ENV['DEBUG']
          # for debugging only
          # This enables tracking of networking requests using Charles Web Proxy
          c.response :logger
          c.proxy "https://127.0.0.1:8888"
        end
      end
    end

    # The logger in which all requests are logged
    # /tmp/spaceship[time].log by default
    def logger
      unless @logger
        if $verbose || ENV["VERBOSE"]
          @logger = Logger.new(STDOUT)
        else
          # Log to file by default
          path = "/tmp/spaceship#{Time.now.to_i}.log"
          @logger = Logger.new(path)
        end

        @logger.formatter = proc do |severity, datetime, progname, msg|
          string = "[#{datetime.strftime('%H:%M:%S')}]: #{msg}\n"
        end
      end

      @logger
    end

    #####################################################
    # @!group Automatic Paging
    #####################################################

    # The page size we want to request, defaults to 500
    def page_size
      @page_size ||= 500
    end

    # Handles the paging for you... for free
    # Just pass a block and use the parameter as page number
    def paging
      page = 0
      results = []
      loop do
        page += 1
        current = yield(page)

        results = results + current

        break if ((current || []).count < page_size) # no more results
      end

      return results
    end

    #####################################################
    # @!group Login and Team Selection
    #####################################################

    # Authenticates with Apple's web services. This method has to be called once
    # to generate a valid session. The session will automatically be used from then
    # on.
    #
    # This method will automatically use the username from the Appfile (if available)
    # and fetch the password from the Keychain (if available)
    #
    # @param user (String) (optional): The username (usually the email address)
    # @param password (String) (optional): The password
    #
    # @raise InvalidUserCredentialsError: raised if authentication failed
    #
    # @return (Spaceship::Client) The client the login method was called for
    def login(user = nil, password = nil)
      if user.to_s.empty? or password.to_s.empty?
        require 'credentials_manager'
        data = CredentialsManager::PasswordManager.shared_manager(user, false)
        user ||= data.username
        password = data.password
      end

      if user.to_s.strip.empty? or password.to_s.strip.empty?
        raise NoUserCredentialsError.new("No login data provided")
      end

      send_login_request(user, password) # different in subclasses
    end

    # @return (Bool) Do we have a valid session?
    def session?
      !!@cookie
    end

    private
      # Is called from `parse_response` to store the latest csrf_token (if available)
      def store_csrf_tokens(response)
        if response and response.headers
          tokens = response.headers.select { |k, v| %w[csrf csrf_ts].include?(k) }
          if tokens and not tokens.empty?
            @csrf_tokens = tokens
          end
        end
      end

      # memoize the last csrf tokens from responses
      def csrf_tokens
        @csrf_tokens || {}
      end

      def request(method, url_or_path = nil, params = nil, headers = {}, &block)
        if session?
          headers.merge!({'Cookie' => cookie})
          headers.merge!(csrf_tokens)
        end
        headers.merge!({'User-Agent' => 'spaceship'})

        # Before encoding the parameters, log them
        log_request(method, url_or_path, params)

        # form-encode the params only if there are params, and the block is not supplied.
        # this is so that certain requests can be made using the block for more control
        if method == :post && params && !block_given?
          params, headers = encode_params(params, headers)
        end

        response = send_request(method, url_or_path, params, headers, &block)

        log_response(method, url_or_path, response)

        return response
      end

      def log_request(method, url, params)
        params_to_log = Hash(params).dup # to also work with nil
        params_to_log.delete(:accountPassword) # Dev Portal
        params_to_log.delete(:theAccountPW) # iTC
        params_to_log = params_to_log.collect do |key, value|
          "{#{key}: #{value}}"
        end
        logger.info("#{method.upcase}: #{url} #{params_to_log.join(', ')}")
      end

      def log_response(method, url, response)
        logger.debug("#{method.upcase}: #{url}: #{response.body}")
      end

      # Actually sends the request to the remote server
      # Automatically retries the request up to 3 times if something goes wrong
      def send_request(method, url_or_path, params, headers, &block)
        tries ||= 5

        return @client.send(method, url_or_path, params, headers, &block)

      rescue Faraday::Error::TimeoutError => ex # New Faraday version: Faraday::TimeoutError => ex
        unless (tries -= 1).zero?
          sleep 3
          retry
        end

        raise ex # re-raise the exception
      end

      def parse_response(response, expected_key = nil)
        if expected_key
          content = response.body[expected_key]
        else
          content = response.body
        end

        if content == nil
          raise UnexpectedResponse.new(response.body)
        else
          store_csrf_tokens(response)
          content
        end
      end

      def encode_params(params, headers)
        params = Faraday::Utils::ParamsHash[params].to_query
        headers = {'Content-Type' => 'application/x-www-form-urlencoded'}.merge(headers)
        return params, headers
      end
  end
end
