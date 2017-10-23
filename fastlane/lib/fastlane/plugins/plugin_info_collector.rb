module Fastlane
  class PluginInfoCollector
    def initialize(ui = PluginGeneratorUI.new)
      @ui = ui
    end

    def collect_info(initial_name = nil)
      plugin_name = collect_plugin_name(initial_name)
      author = collect_author(detect_author)
      email = collect_email(detect_email)
      summary = collect_summary
      details = collect_details

      PluginInfo.new(plugin_name, author, email, summary, details)
    end

    #
    # Plugin name
    #

    def collect_plugin_name(initial_name = nil)
      plugin_name = initial_name
      first_try = true

      loop do
        if !first_try || plugin_name.to_s.empty?
          plugin_name = @ui.input("What would you like to be the name of your plugin?")
        end
        first_try = false

        unless plugin_name_valid?(plugin_name)
          fixed_name = fix_plugin_name(plugin_name)

          if plugin_name_valid?(fixed_name)
            plugin_name = fixed_name if @ui.confirm("\nWould '#{fixed_name}' be okay to use for your plugin name?")
          end
        end

        break if plugin_name_valid?(plugin_name)

        gem_name = PluginManager.to_gem_name(plugin_name)

        if gem_name_taken?(gem_name)
          # Gem name is already taken on RubyGems
          @ui.message("\nThe gem name '#{gem_name}' is already taken on RubyGems, please choose a different plugin name.")
        else
          # That's a naming error
          @ui.message("\nPlugin names can only contain lower case letters, numbers, and underscores")
          @ui.message("and should not contain 'fastlane' or 'plugin'.")
        end
      end

      plugin_name
    end

    def plugin_name_valid?(name)
      # Only lower case letters, numbers and underscores allowed
      /^[a-z0-9_]+$/ =~ name &&
        # Does not contain the words 'fastlane' or 'plugin' since those will become
        # part of the gem name
        [/fastlane/, /plugin/].none? { |regex| regex =~ name } &&
        # Gem name isn't taken on RubyGems yet
        !gem_name_taken?(PluginManager.to_gem_name(name))
    end

    # Checks if the gem name is still free on RubyGems
    def gem_name_taken?(name)
      require 'open-uri'
      require 'json'
      url = "https://rubygems.org/api/v1/gems/#{name}.json"
      response = JSON.parse(open(url).read)
      return !!response['version']
    rescue
      false
    end

    # Applies a series of replacement rules to turn the requested plugin name into one
    # that is acceptable, returning that suggestion
    def fix_plugin_name(name)
      name = name.to_s.downcase
      fixes = {
        /[\- ]/ => '_', # dashes and spaces become underscores
        /[^a-z0-9_]/ => '', # anything other than lower case letters, numbers and underscores is removed
        /fastlane[_]?/ => '', # 'fastlane' or 'fastlane_' is removed
        /plugin[_]?/ => '' # 'plugin' or 'plugin_' is removed
      }
      fixes.each do |regex, replacement|
        name = name.gsub(regex, replacement)
      end
      name
    end

    #
    # Author
    #

    def detect_author
      git_name = Helper.backticks('git config --get user.name', print: FastlaneCore::Globals.verbose?).strip
      return git_name.empty? ? nil : git_name
    end

    def collect_author(initial_author = nil)
      return initial_author if author_valid?(initial_author)
      author = nil
      loop do
        author = @ui.input("What is the plugin author's name?")
        break if author_valid?(author)

        @ui.message('An author name is required.')
      end

      author
    end

    def author_valid?(author)
      !author.to_s.strip.empty?
    end

    #
    # Email
    #

    def detect_email
      git_email = Helper.backticks('git config --get user.email', print: FastlaneCore::Globals.verbose?).strip
      return git_email.empty? ? nil : git_email
    end

    def collect_email(initial_email = nil)
      return initial_email || @ui.input("What is the plugin author's email address?")
    end

    #
    # Summary
    #

    def collect_summary
      summary = nil
      loop do
        summary = @ui.input("Please enter a short summary of this fastlane plugin:")
        break if summary_valid?(summary)

        @ui.message('A summary is required.')
      end

      summary
    end

    def summary_valid?(summary)
      !summary.to_s.strip.empty?
    end
    #
    # Summary
    #

    def collect_details
      return @ui.input("Please enter a detailed description of this fastlane plugin:").to_s
    end
  end
end
