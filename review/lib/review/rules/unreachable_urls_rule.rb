require 'review/rule'

module Review
  class UnreachableURLRule < URLRule
    def self.key
      :unreachable_urls
    end

    def self.env_name
      "RULE_UNREACHABLE_URLS"
    end

    def self.description
      "All URLs given to App Review must resolve"
    end

    def self.rule_block
      return lambda { |url|
        url = url.to_s.strip
        return Review::VALIDATION_STATES[:fail] if url.empty?

        begin
          return Review::VALIDATION_STATES[:fail] unless Faraday.head(url).status == 200
        rescue
          UI.error "URL #{url} not reachable 😵"
          return Review::VALIDATION_STATES[:fail]
        end

        return Review::VALIDATION_STATES[:pass]
      }
    end
  end
end
