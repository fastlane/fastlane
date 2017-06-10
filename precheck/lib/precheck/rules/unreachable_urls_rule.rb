require 'precheck/rule'

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

    def self.rule_block
      return lambda { |url|
        url = url.to_s.strip
        return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:fail], failure_data: "empty url") if url.empty?

        begin
          return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:fail], failure_data: url) unless Faraday.head(url).status == 200
        rescue
          UI.verbose "URL #{url} not reachable 😵"
          # I can only return :fail here, but I also want to return #{url}
          return RuleReturn.new(validation_state: VALIDATION_STATES[:fail], failure_data: "unreachable: #{url}")
        end

        return RuleReturn.new(validation_state: VALIDATION_STATES[:pass])
      }
    end
  end
end
