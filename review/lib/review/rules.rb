require 'review/rule'

module Review
  module Rules
    def apple_things_rule
      rule_block = lambda { |text|
        matches = []
        text.to_s.scan(/apple|ios|macos|osx/i) { matches << $~ }
        if matches.length > 0
          matched = matches.map(&:to_s)
          UI.error "Found Apple words \"#{matched}\" 😭"
          Review::VALIDATION_STATES[:fail]
        else
          Review::VALIDATION_STATES[:pass]
        end
      }

      Review::TextRule.new(key: :apple_things,
                      env_name: "RULE_APPLE_THINGS",
                   description: "Don't use Apple's or its products names",
                 default_value: CredentialsManager::AppfileConfig.try_fetch_value(:apple_things),
                    rule_block: rule_block)
    end

    def unreachable_urls_rule
      rule_block = lambda { |url|
        return Review::VALIDATION_STATES[:fail] if url.to_s.strip.empty?

        begin
          return Review::VALIDATION_STATES[:fail] unless Faraday.head(url).status == 200
        rescue
          UI.error "URL #{url} not reachable 😵"
          return Review::VALIDATION_STATES[:fail]
        end

        return Review::VALIDATION_STATES[:pass]
      }

      Review::URLRule.new(key: :unreachable_urls,
                      env_name: "RULE_UNREACHABLE_URLS",
                   description: "All URLs given to App Review must resolve",
                 default_value: CredentialsManager::AppfileConfig.try_fetch_value(:unreachable_urls),
                    rule_block: rule_block)
    end

    def all_rules
      [apple_things_rule, unreachable_urls_rule]
    end

    module_function :all_rules
    module_function :apple_things_rule
    module_function :unreachable_urls_rule
  end
end
