require 'pry'
module Fastlane
  class MarkdownDocsGenerator
    ENHANCER_URL = "https://fastlane-enhancer.herokuapp.com"

    attr_accessor :categories

    def initialize
      require 'fastlane'
      require 'fastlane/documentation/actions_list'
      Fastlane.load_actions

      self.work
    end

    def work
      self.categories = {}
      Fastlane::Action::AVAILABLE_CATEGORIES.each { |a| self.categories[readable_category_name(a)] = {} }
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
      require 'faraday'
      require 'json'

      unless @launches
        conn = Faraday.new(ENHANCER_URL)
        conn.basic_auth(ENV["ENHANCER_USER"], ENV["ENHANCER_PASSWORD"])
        @launches = JSON.parse(conn.get('/index.json').body)
      end

      found = @launches.find { |c| c["action"] == action_name.to_s }

      return found["launches"] if found
      return rand # so we don't overwrite another action, this is between 0 and 1
    end

    def generate!(target_path: "docs/ActionsAuto.md")
      template = File.join(Helper.gem_path('fastlane'), "lib/assets/Actions.md.erb")

      result = ERB.new(File.read(template), 0, '-').result(binding) # http://www.rrn.dk/rubys-erb-templating-system
      puts result

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
      when :screenshots
        "Screenshots"
      when :project
        "Project"
      when :beta
        "Beta"
      when :production
        "Releasing your app"
      else
        category_symbol.to_s.capitalize
      end
    end
  end
end
