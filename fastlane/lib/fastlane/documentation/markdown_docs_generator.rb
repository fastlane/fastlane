module Fastlane
  class MarkdownDocsGenerator
    ENHANCER_URL = "https://enhancer.fastlane.tools"

    attr_accessor :categories

    def initialize
      require 'fastlane'
      require 'fastlane/documentation/actions_list'
      Fastlane.load_actions

      self.work
    end

    def work
      fill_built_in_actions
    end

    def fill_built_in_actions
      self.categories = {}

      Fastlane::Action::AVAILABLE_CATEGORIES.each { |a| self.categories[readable_category_name(a)] = {} }

      # Fill categories with all built-in actions
      ActionsList.all_actions do |action|
        readable = readable_category_name(action.category)

        if self.categories[readable].kind_of?(Hash)
          self.categories[readable][number_of_launches_for_action(action.action_name)] = action
        else
          UI.error("Action '#{action.name}' doesn't contain category information... skipping")
        end
      end
    end

    def number_of_launches_for_action(action_name)
      found = all_actions_from_enhancer.find { |c| c["action"] == action_name.to_s }

      return found["launches"] if found
      return rand # so we don't overwrite another action, this is between 0 and 1
    end

    def all_actions_from_enhancer
      require 'faraday'
      require 'json'

      # Only Fabric team members have access to the enhancer instance
      # This can be used to check doc changes for everyone else
      if FastlaneCore::Env.truthy?('USE_ENHANCE_TEST_DATA')
        return [{ "action" => "puts", "launches" => 123, "errors" => 0, "ratio" => 0.0, "crashes" => 0 },
                { "action" => "fastlane_version", "launches" => 123, "errors" => 43, "ratio" => 0.34, "crashes" => 0 },
                { "action" => "default_platform", "launches" => 123, "errors" => 33, "ratio" => 0.27, "crashes" => 31 }]
      end

      unless @launches
        conn = Faraday.new(ENHANCER_URL)
        conn.basic_auth(ENV["ENHANCER_USER"], ENV["ENHANCER_PASSWORD"])
        begin
          @launches = JSON.parse(conn.get('/index.json?minimum_launches=0').body)
        rescue
          UI.user_error!("Couldn't fetch usage data, make sure to have ENHANCER_USER and ENHANCER_PASSWORD")
        end
      end
      @launches
    end

    def generate!(target_path: "docs/Actions.md")
      template = File.join(Fastlane::ROOT, "lib/assets/Actions.md.erb")

      result = ERB.new(File.read(template), 0, '-').result(binding) # http://www.rrn.dk/rubys-erb-templating-system
      UI.verbose(result)

      File.write(target_path, result)
      UI.success(target_path)
    end

    private

    def readable_category_name(category_symbol)
      case category_symbol
      when :misc
        "Misc"
      when :source_control
        "Source Control"
      when :notifications
        "Notifications"
      when :code_signing
        "Code Signing"
      when :documentation
        "Documentation"
      when :testing
        "Testing"
      when :building
        "Building"
      when :push
        "Push"
      when :screenshots
        "Screenshots"
      when :project
        "Project"
      when :beta
        "Beta"
      when :production
        "Releasing your app"
      when :deprecated
        "Deprecated"
      else
        category_symbol.to_s.capitalize
      end
    end
  end
end
