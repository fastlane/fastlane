require 'addressable'
require 'faraday_middleware'

require_relative '../rule'

module Precheck
  class UnreachableURLRule < URLRule
    def self.key
      :unreachable_urls
    end

    def self.env_name
      "RULE_UNREACHABLE_URLS"
    end

    def self.friendly_name
      "No broken urls"
    end

    def self.description
      "unreachable URLs in app metadata"
    end

    def rule_block
      return lambda { |url|
        url = url.to_s.strip
        return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "empty url") if url.empty?

        begin
          uri = Addressable::URI.parse(url)
          uri.fragment = nil
          request = Faraday.new(uri.normalize.to_s) do |connection|
            connection.use(FaradayMiddleware::FollowRedirects)
            connection.adapter(:net_http)
          end
          return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: url) unless request.head.status == 200
        rescue StandardError => e
          UI.verbose("URL #{url} not reachable 😵: #{e.message}")
          # I can only return :fail here, but I also want to return #{url}
          return RuleReturn.new(validation_state: VALIDATION_STATES[:failed], failure_data: "unreachable: #{url}")
        end

        return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
      }
    end
  end
end
