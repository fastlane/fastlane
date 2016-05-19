require 'bundler_support/ui'
require 'bundler'

module BundlerSupport
  class BundlerManager
    DEFAULT_GEMFILE_PATH = "Gemfile".freeze
    GEMFILE_SOURCE_LINE = "source \"https://rubygems.org\"\n".freeze
    FASTLANE_GEM_CODE = "\ngem 'fastlane'\n".freeze
    RUN_AGAIN_TEXT = " Please run your command again.".freeze

    attr_reader :ui

    def initialize(ui = UI.new)
      @ui = ui
    end

    def setup_bundler
      ensure_gemfile_valid!

      begin
        Bundler.setup
      rescue Bundler::GemNotFound
        ui.message 'Some of your dependencies could not be found. Trying to install them...'
        install_dependencies!(suggest_run_again: true)
      end
    end

    def ensure_gemfile_valid!
      path_to_gemfile = gemfile_path
      return if path_to_gemfile && gemfile_has_fastlane?(path_to_gemfile)

      ui.message 'It looks like this project is not set up to use fastlane through Bundler yet'

      if path_to_gemfile && File.exist?(path_to_gemfile)
        verb = 'update'
        subject = "your #{path_to_gemfile}"
        discovered_gems = gems_from_gemfile(path_to_gemfile)
        gemfile_content = File.read(path_to_gemfile) + FASTLANE_GEM_CODE
      else
        verb = 'create'
        subject = 'a Gemfile'
        path_to_gemfile = DEFAULT_GEMFILE_PATH
        discovered_gems = []
        gemfile_content = GEMFILE_SOURCE_LINE + FASTLANE_GEM_CODE
      end

      if ui.confirm("Can fastlane #{verb} #{subject} for you? (y/n)")
        File.write(path_to_gemfile, gemfile_content)
        ui.message "Successfully modified '#{path_to_gemfile}'"
      else
        ui.message "\nNo problem! Please add the following code to '#{path_to_gemfile}' and run fastlane again:\n\n"
        ui.indent gemfile_content, 2
        abort
      end
    end

    # Warning: This will exec out
    # This is necessary since the user might be prompted for their password
    def install_dependencies!(suggest_run_again: false)
      ui.message "Installing dependencies..."
      ensure_gemfile_valid!

      command = "bundle install --quiet && echo 'Dependencies installed!"
      command += RUN_AGAIN_TEXT if suggest_run_again
      command += "'"
      with_clean_bundler_env { exec(command) }
    end

    # Warning: This will exec out
    # This is necessary since the user might be prompted for their password
    def update_dependencies!(suggest_run_again: false)
      ui.message "Updating dependencies..."
      ensure_gemfile_valid!

      command = "bundle update --quiet && echo 'Dependencies updated!"
      command += RUN_AGAIN_TEXT if suggest_run_again
      command += "'"
      with_clean_bundler_env { exec(command) }
    end

    def gemfile_path
      # This is pretty important, since we don't know what kind of
      # Gemfile the user has (e.g. Gemfile, gems.rb, or custom env variable)
      Bundler::SharedHelpers.default_gemfile.to_s
    rescue Bundler::GemfileNotFound
      nil
    end

    def gemfile_has_fastlane?(path_to_gemfile)
      gems_from_gemfile(path_to_gemfile).include?('fastlane')
    end

    def gems_from_gemfile(path_to_gemfile)
      Bundler::Dsl.evaluate(path_to_gemfile, nil, true).dependencies.map(&:name)
    end

    def with_clean_bundler_env
      # There is an interesting problem with using exec to call back into Bundler
      # The `bundle ________` command that we exec, inherits all of the Bundler
      # state we'd already built up during this run. That was causing the command
      # to fail, telling us to install the Gem we'd just introduced, even though
      # that is exactly what we are trying to do!
      #
      # Bundler.with_clean_env solves this problem by resetting Bundler state before the
      # exec'd call gets merged into this process.
      Bundler.with_clean_env do
        yield if block_given?
      end
    end
  end
end
