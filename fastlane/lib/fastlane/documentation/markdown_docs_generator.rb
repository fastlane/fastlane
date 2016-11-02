module Fastlane
  class MarkdownDocsGenerator
    ENHANCER_URL = "https://fastlane-enhancer.herokuapp.com"

    attr_accessor :categories

    attr_accessor :plugins

    def initialize
      require 'fastlane'
      require 'fastlane/documentation/actions_list'
      Fastlane.load_actions

      self.work
    end

    def work
      fill_built_in_actions
      fill_plugins
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

    def fill_plugins
      self.plugins = []

      all_fastlane_plugins = PluginFetcher.fetch_gems # that's all available gems

      # We iterate over the enhancer data, since this includes the various actions per plugin
      # we then access `all_fastlane_plugins` to get the URL to the plugin
      all_actions_from_enhancer.each do |current_action|
        action_name = current_action["action"] # e.g. "fastlane-plugin-synx/synx"

        next unless action_name.start_with?("fastlane-plugin") # we only care about plugins here

        gem_name = action_name.split("/").first # e.g. fastlane-plugin-synx
        ruby_gem_info = all_fastlane_plugins.find { |a| a.full_name == gem_name }

        next unless ruby_gem_info

        # `ruby_gem_info` e.g.
        #
        # #<Fastlane::FastlanePlugin:0x007ff7fc4de9e0
        #  @downloads=888,
        #  @full_name="fastlane-plugin-synx",
        #  @homepage="https://github.com/afonsograca/fastlane-plugin-synx",
        #  @info="Organise your Xcode project folder to match your Xcode groups.",
        #  @name="synx">

        self.plugins << {
          linked_title: ruby_gem_info.linked_title,
          action_name: action_name.split("/").last,
          description: ruby_gem_info.info,
          usage: number_of_launches_for_action(action_name)
        }
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

      unless @launches
        conn = Faraday.new(ENHANCER_URL)
        conn.basic_auth(ENV["ENHANCER_USER"], ENV["ENHANCER_PASSWORD"])
        begin
          @launches = JSON.parse(conn.get('/index.json').body)
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
