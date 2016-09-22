module Fastlane
  class EnvironmentPrinter
    def self.print
      puts "### Fastlane Environment"
      puts ""
      print_system_environment
      print_fastlane_files
      print_loaded_gems
      print_loaded_plugins
      print_instructions
    end

    def self.print_instructions
      puts "Please file a new issue by going to: https://github.com/fastlane/fastlane/issues/new"
      puts "and do fastlane env|pbcopy  to get the report into pasteboard"
    end

    def self.print_loaded_plugins
      ENV["FASTLANE_ENV_PRINTER"] = "enabled"
      puts "### Loaded Fastlane Plugins:"
      puts ""
      plugin_manager = Fastlane::PluginManager.new
      plugin_manager.load_plugins
      if plugin_manager.available_plugins.length <= 0
        puts "**No Plugins Loaded***"
      else
        puts "| Plugin | Version |"
        puts "|--------|---------|"
        plugin_manager.available_plugins.each do |plugin|
          puts "| #{plugin} | #{Fastlane::ActionCollector.determine_version(plugin)} |"
        end
      end

      puts " "
      puts " "
    end

    def self.print_loaded_gems
      puts "### Loaded Gems"
      puts ""
      puts "| Gem | Version |"
      puts "|-----|---------|"
      puts Gem.loaded_specs.values.map { |x| "| #{x.name} | #{x.version} |" }
      puts " "
      puts " "
    end

    def self.print_system_environment
      puts "### Stack"
      puts ""
      puts "| Key |  Value |"
      puts "|-----|---------|"
      puts "| Fastlane | #{Fastlane::VERSION} |"
      puts "| OS  | #{`sw_vers -productVersion`.strip}|"
      puts "| Ruby  | #{RUBY_VERSION}|"
      puts "| Xcode | #{`xcode-select -p`.strip.tr("\n", ' ')}|"
      puts "| Xcode Version | #{`xcodebuild -version`.strip.tr("\n", ' ')}|"
      puts "| Git | #{`git --version`.strip.split("\n").first} |"
      puts "| Installation Source | #{$PROGRAM_NAME} |"

      product, version, build = `sw_vers`.strip.split("\n").map { |line| line.split(':').last.strip }

      puts "| Host | #{product} #{version} (#{build}) |"
      puts "| Ruby Lib Dir | #{RbConfig::CONFIG['libdir']}|"

      puts " "
      puts " "
    end

    def self.print_fastlane_files
      puts "### Fastlane Files:"
      puts ""

      fastlane_path = FastlaneFolder.fastfile_path

      if File.exist?(fastlane_path)
        puts "`Fastfile` located in #{fastlane_path}"
        puts ""
        puts "```"
        puts File.read(fastlane_path)
        puts "```"
      else
        puts "No Fastfile found"
      end
      puts ""

      appfile_path = CredentialsManager::AppfileConfig.default_path
      if File.exist?(appfile_path)
        puts "`Appfile` located in #{appfile_path}"
        puts ""
        puts "```"
        puts File.read(appfile_path)
        puts "```"
      else
        puts "No Appfile found"
      end
      puts ""
    end
  end
end
