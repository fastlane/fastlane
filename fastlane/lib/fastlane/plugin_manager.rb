module Fastlane
  class PluginManager
    GEMFILE_NAME = "FastlaneGemfile"

    attr_accessor :dependencies

    def dependencies
      @dependencies ||= []
    end

    def add_dependency(plugin_name)
      dependencies << plugin_name
    end

    def install_dependencies
      require 'tmpdir'

      temp = Dir.mktmpdir("fastlane")

      # Copy a previously created .lock file (if it exists)
      previous_lock_path = File.join(FastlaneFolder.path, "#{GEMFILE_NAME}.lock")
      FileUtils.cp(previous_lock_path, temp) if File.exist?(previous_lock_path)

      puts File.exist?(previous_lock_path)      

      # Generate a temporary Gemfile
      str = []
      str << 'source "https://rubygems.org"'
      dependencies.each do |current|
        str << "gem '#{current}'"
      end
      # We also need to have fastlane here, with the version we're currently using
      str << "gem 'fastlane', '= #{Fastlane::VERSION}'"

      gemfile_path = File.join(temp, GEMFILE_NAME)
      File.write(gemfile_path, str.join("\n"))
      puts "Using Gemfile at path '#{gemfile_path}'"

      ENV["BUNDLE_GEMFILE"] = gemfile_path
      puts `bundle install --path '~/.fastlane/gems/'`

      # Now copy over the .lock file into the repo
      FileUtils.cp(File.join(temp, "#{GEMFILE_NAME}.lock"), FastlaneFolder.path)

      experiments # TOD: Temporary
    end

    def update_dependencies
      # TODO
      # This will check if the user has a Gemfile, if so, it tells the user to run `bundle update` instead
      # If not, it will run `bundle update` and store the updated .lock file
    end

    def experiments
      puts `bundle exec fastlane -v`
      puts `bundle exec pem -v`
      puts `bundle exec fastlane actions | wc -l`
    end
  end
end
