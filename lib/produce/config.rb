module Produce
  class Config
    attr_accessor :config

    def self.shared_config
      @@shared ||= self.new
    end

    def initialize
      Helper.log.info "Loaded config".green
      @config = {
        :bundle_identifier => 'tools.fastlane.automatic',
        :app_name => 'Created by Fastlane',
        :primary_language => 'German',
        :version => '0.1',
        :sku => 1343,
        :pricing_tier => 0,
        :rating => nil,
        :app_review => {

        }
      }
    end

    def self.val(key)
      raise "Please only pass symbols, no Strings to this method".red unless key.kind_of?Symbol
      self.shared_config.config[key]
    end
  end
end