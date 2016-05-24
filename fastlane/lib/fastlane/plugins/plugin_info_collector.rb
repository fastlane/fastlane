module Fastlane
  class PluginInfoCollector
    def initialize(ui = PluginGeneratorUI.new)
      @ui = ui
    end

    def collect_info(initial_name = nil)
      plugin_name = collect_plugin_name(initial_name)
      author = collect_author
      email = collect_email
      summary = collect_summary
      description = collect_description

      PluginInfo.new(plugin_name, author, email, summary, description)
    end

    #
    # Plugin name
    #

    def collect_plugin_name(initial_name = nil)
      plugin_name = initial_name
      first_try = true

      loop do
        if !first_try || plugin_name.to_s.empty?
          plugin_name = @ui.input("\nWhat would you like to be the name of your plugin?")
        end
        first_try = false

        unless plugin_name_valid?(plugin_name)
          fixed_name = fix_plugin_name(plugin_name)

          if plugin_name_valid?(fixed_name)
            plugin_name = fixed_name if @ui.confirm("\nWould '#{fixed_name}' be okay to use for your plugin name?")
          end
        end

        break if plugin_name_valid?(plugin_name)

        @ui.message("\nPlugin names can only contain lower case letters, numbers, and underscores")
        @ui.message("and should not contain 'fastlane' or 'plugin'.")
      end

      plugin_name
    end

    def plugin_name_valid?(name)
      # Only lower case letters, numbers and underscores allowed
      /^[a-z0-9_]+$/ =~ name &&
        # Does not contain the words 'fastlane' or 'plugin' since those will become
        # part of the gem name
        [/fastlane/, /plugin/].none? { |regex| regex =~ name }
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

    def collect_author
      author = nil
      loop do
        author = @ui.input("\nWhat is the plugin author's name?")
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

    def collect_email
      @ui.input("\nWhat is the plugin author's email address?")
    end

    #
    # Summary
    #

    def collect_summary
      summary = nil
      loop do
        summary = @ui.input("\nPlease enter a short summary of this fastlane plugin:")
        break if summary_valid?(summary)

        @ui.message('A summary is required.')
      end

      summary
    end

    def summary_valid?(summary)
      !summary.to_s.strip.empty?
    end

    #
    # Description
    #

    def collect_description
      @ui.input("\nPlease enter a longer description of this fastlane plugin:")
    end

  end
end
