module Fastlane
  class EnvironmentPrinter
    def self.get
      require "fastlane/markdown_table_formatter"
      env_output = ""
      env_output << "### fastlane Environment\n"
      env_output << "\n"
      env_output << print_system_environment
      env_output << print_fastlane_files
      env_output << print_loaded_fastlane_gems
      env_output << print_loaded_plugins
      env_output << print_loaded_gems
      env_output << print_date
      env_output
    end

    def self.print_date
      date = Time.now.strftime("%d/%m/%Y %H:%M")
      "\n *generated at:* **#{date}** \n"
    end

    def self.print_loaded_plugins
      ENV["FASTLANE_ENV_PRINTER"] = "enabled"
      env_output =  "### Loaded fastlane Plugins:\n"
      env_output << "\n"
      plugin_manager = Fastlane::PluginManager.new
      plugin_manager.load_plugins
      if plugin_manager.available_plugins.length <= 0
        env_output << "**No Plugins Loaded***\n"
      else
        table = ""
        table << "| Plugin | Version | Update-Status |\n"
        table << "|--------|---------|\n"
        plugin_manager.available_plugins.each do |plugin|
          begin
          installed_version = Fastlane::ActionCollector.determine_version(plugin)
          update_url = FastlaneCore::UpdateChecker.generate_fetch_url(plugin)
          latest_version = FastlaneCore::UpdateChecker.fetch_latest(update_url)
          if Gem::Version.new(installed_version) == Gem::Version.new(latest_version)
            update_status = "✅ Up-To-Date"
          else
            update_status = "🚫 Update availaible"
          end
        rescue
          update_status = "💥 Check failed"
        end
          table << "| #{plugin} | #{installed_version} | #{update_status} |\n"
        end

        rendered_table = MarkdownTableFormatter.new table
        env_output << rendered_table.to_md
      end

      env_output << "\n\n"
      env_output
    end

    def self.print_loaded_fastlane_gems
      # fastlanes own gems
      env_output = "### fastlane gems\n\n"
      table = ""
      table << "| Gem | Version | Update-Status |\n"
      table << "|-----|---------|------------|\n"
      Gem.loaded_specs.values.each do |x|
        update_status = "N/A"

        next unless Fastlane::TOOLS.include?(x.name.to_sym)
        begin
          update_url = FastlaneCore::UpdateChecker.generate_fetch_url(x.name)
          latest_version = FastlaneCore::UpdateChecker.fetch_latest(update_url)
          if Gem::Version.new(x.version) == Gem::Version.new(latest_version)
            update_status = "✅ Up-To-Date"
          else
            update_status = "🚫 Update availaible"
          end
        rescue
          update_status = "💥 Check failed"
        end
        table << "| #{x.name} | #{x.version} | #{update_status} |\n"
      end

      rendered_table = MarkdownTableFormatter.new table
      env_output << rendered_table.to_md

      env_output << "\n\n"

      env_output
    end

    def self.print_loaded_gems
      env_output = "### Loaded Gems\n\n"
      table = ""
      table << "| Gem | Version |\n"
      table << "|-----|---------|\n"
      Gem.loaded_specs.values.each do |x|
        unless Fastlane::TOOLS.include?(x.name.to_sym)
          table << "| #{x.name} | #{x.version} |\n"
        end
      end
      rendered_table = MarkdownTableFormatter.new table
      env_output << rendered_table.to_md

      env_output << "\n\n"

      env_output
    end

    def self.print_system_environment
      require "openssl"

      env_output = "### Stack\n\n"
      product, version, build = `sw_vers`.strip.split("\n").map { |line| line.split(':').last.strip }
      table = ""
      table << "| Key |  Value |\n"
      table << "|-----|---------|\n"
      table << "| fastlane | #{Fastlane::VERSION} |\n"
      table << "| OS  | #{`sw_vers -productVersion`.strip}|\n"
      table << "| Ruby  | #{RUBY_VERSION}|\n"
      table << "| Xcode | #{`xcode-select -p`.strip.tr("\n", ' ')}|\n"
      table << "| Xcode Version | #{`xcodebuild -version`.strip.tr("\n", ' ')}|\n"
      table << "| Git | #{`git --version`.strip.split("\n").first} |\n"
      table << "| Installation Source | #{$PROGRAM_NAME} |\n"
      table << "| Host | #{product} #{version} (#{build}) |\n"
      table << "| Ruby Lib Dir | #{RbConfig::CONFIG['libdir']}|\n"
      table << "| OpenSSL Version | #{OpenSSL::OPENSSL_VERSION} |\n"

      rendered_table = MarkdownTableFormatter.new table
      env_output << rendered_table.to_md

      env_output << "\n\n"
      env_output
    end

    def self.print_fastlane_files
      env_output = "### fastlane Files:\n\n"

      fastlane_path = FastlaneFolder.fastfile_path

      if fastlane_path && File.exist?(fastlane_path)
        env_output << "`Fastfile` located in #{fastlane_path}\n"
        env_output << "\n"
        env_output << "```\n"
        env_output <<  File.read(fastlane_path)
        env_output <<  "```\n"
      else
        env_output << "**No Fastfile found**\n"
      end
      env_output << "\n\n"

      appfile_path = CredentialsManager::AppfileConfig.default_path
      if appfile_path && File.exist?(appfile_path)
        env_output << "`Appfile` located in #{appfile_path}\n"
        env_output << "\n"
        env_output << "```\n"
        env_output <<  File.read(appfile_path)
        env_output <<  "```\n"
      else
        env_output <<  "**No Appfile found**\n"
      end
      env_output << "\n\n"
      env_output
    end
  end
end
