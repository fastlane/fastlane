module Fastlane
  class EnvironmentPrinter
    def self.print
      puts "My fastlane environment"
      print_system_environment
      print_ruby_environment
      print_fastlane_properties
      print_appfile
    end

    def self.print_system_environment
      puts "My OS version is: #{`sw_vers -productVersion`.strip}"
    end

    def self.print_ruby_environment
      puts "Ruby version #{RUBY_VERSION}"
    end

    def self.print_fastlane_properties
      # prints the fastfile
      fastlane_path = FastlaneFolder.fastfile_path
      puts "fastfile located at: #{fastlane_path}"
      puts "```"
      puts File.read(fastlane_path)
      puts "```"
    end

    def self.print_appfile
      # prints the fastfile
      appfile_path = CredentialsManager::AppfileConfig.default_path
      puts "appfile located at: #{appfile_path}"
      puts "```"
      puts File.read(appfile_path)
      puts "```"
    end
  end
end
