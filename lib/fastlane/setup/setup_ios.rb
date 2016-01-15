module Fastlane
  class SetupIos < Setup
    # the tools that are already enabled
    attr_reader :tools

    def run
      if FastlaneFolder.setup? and !Helper.is_test?
        Helper.log.info "Fastlane already set up at path #{folder}".yellow
        return
      end

      show_infos

      # rubocop:disable Lint/RescueException
      begin
        FastlaneFolder.create_folder! unless Helper.is_test?
        setup_default_project
        if UI.confirm("Please confirm the above values")
          copy_existing_files
          default_generate_appfile
          detect_installed_tools # after copying the existing files
          enable_deliver
          FileUtils.mkdir(File.join(FastlaneFolder.path, 'actions'))
          default_generate_fastfile
          show_analytics
        else
          # TODO
        end
        Helper.log.info 'Successfully finished setting up fastlane'.green
      rescue => ex # this will also be caused by Ctrl + C
        # Something went wrong with the setup, clear the folder again
        # and restore previous files
        Helper.log.fatal 'Error occurred with the setup program! Reverting changes now!'.red
        restore_previous_state
        raise ex
      end
      # rubocop:enable Lint/RescueException
    end

    def setup_default_project
      config = {}
      FastlaneCore::Project.detect_projects(config)
      @project = FastlaneCore::Project.new(config)
      @project.default_app_identifier
      @project.default_app_name
      ask_for_apple_id
      detect_if_app_is_available
      print_config_table
    end

    def print_config_table
      rows = []
      rows << ["Apple ID", @apple_id]
      rows << ["App Name", @project.default_app_name]
      rows << ["App Identifier", @project.default_app_identifier]
      rows << [(@project.is_workspace ? "Workspace" : "Project"), @project.path]
      require 'terminal-table'
      puts ""
      puts Terminal::Table.new(rows: rows, title: "Detected Values")
      puts ""

      unless @itc_ref
        UI.important "This app identifier doesn't exist on iTunes Connect yet, it will be created for you"
      end

      unless @portal_ref
        UI.important "This app identifier doesn't exist on the Apple Developer Portal yet, it will be created for you"
      end
    end

    def show_infos
      Helper.log.info 'This setup will help you get up and running in no time.'.green
      Helper.log.info 'First, it will move the config files from `deliver` and `snapshot`'.green
      Helper.log.info "into the subfolder `fastlane`.\n".green
      Helper.log.info "fastlane will check what tools you're already using and set up".green
      Helper.log.info 'the tool automatically for you. Have fun! '.green
    end

    def files_to_copy
      ['Deliverfile', 'deliver', 'screenshots']
    end

    def copy_existing_files
      files_to_copy.each do |current|
        current = File.join(File.expand_path('..', FastlaneFolder.path), current)
        next unless File.exist?(current)
        file_name = File.basename(current)
        to_path = File.join(folder, file_name)
        Helper.log.info "Moving '#{current}' to '#{to_path}'".green
        FileUtils.mv(current, to_path)
      end
    end

    def default_generate_appfile
      # get the proper xcodeproj/workspace and determine the bundle_id
      # team ID
      create_appfile(@project.default_app_identifier)
    end

    def ask_for_apple_id
      @apple_id = ask('Your Apple ID (e.g. fastlane@krausefx.com): '.yellow)
    end

    def create_appfile(app_identifier)
      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/AppfileTemplate")
      template.gsub!('[[APP_IDENTIFIER]]', app_identifier)
      template.gsub!('[[APPLE_ID]]', @apple_id)
      path = File.join(folder, 'Appfile')
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your preferred app metadata information.".green
    end

    # Detect if the app was created on the Dev Portal / iTC
    def detect_if_app_is_available
      require 'spaceship'

      UI.important "Verifying if app is available on the Apple Developer Portal and iTunes Connect..."
      UI.message "Starting login with user '#{@apple_id}'"
      Spaceship.login(@apple_id, nil)
      @dev_portal_team = Spaceship.select_team # TODO: add @dev_portal_team to the Appfile
      @portal_ref = Spaceship::App.find(@project.default_app_identifier)
      
      Spaceship::Tunes.login(@apple_id, nil)
      @itc_team = Spaceship::Tunes.select_team
      @itc_ref = Spaceship::Application.find(@project.default_app_identifier)
    end

    def create_app
      Helper.log.info "Running produce..."
      require 'produce'
      config = {}
      FastlaneCore::Project.detect_projects(config)
      project = FastlaneCore::Project.new(config)

      produce_options_hash = {
        app_name: project.default_app_name
      }
      Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, produce_options_hash)
      begin
        ENV['PRODUCE_APPLE_ID'] = Produce::Manager.start_producing
      rescue => exception
        if exception.to_s.include?("The App Name you entered has already been used")
          Helper.log.info "It looks like that #{project.default_app_name} has already been taken, please enter an alternative.".yellow
          Produce.config[:app_name] = ask("App Name: ".yellow)
          Produce.config[:skip_devcenter] = true
          ENV['PRODUCE_APPLE_ID'] = Produce::Manager.start_producing
        end
      end
    end

    def detect_installed_tools
      @tools = {}
      @tools[:deliver] = File.exist?(File.join(folder, 'Deliverfile'))
      @tools[:snapshot] = File.exist?(File.join(folder, 'Snapfile'))
      @tools[:xctool] = File.exist?(File.join(File.expand_path('..', folder), '.xctool-args'))
      @tools[:cocoapods] = File.exist?(File.join(File.expand_path('..', folder), 'Podfile'))
      @tools[:carthage] = File.exist?(File.join(File.expand_path('..', folder), 'Cartfile'))
      @tools[:sigh] = false
    end

    def enable_snapshot
      Helper.log.info "Loading up 'snapshot', this might take a few seconds"

      require 'snapshot'
      require 'snapshot/setup'
      Snapshot::Setup.create(folder)

      @tools[:snapshot] = true
    end

    def enable_deliver
      Helper.log.info "Loading up 'deliver', this might take a few seconds"
      require 'deliver'
      require 'deliver/setup'
      options = FastlaneCore::Configuration.create(Deliver::Options.available_options, {})
      Deliver::Runner.new(options) # to login...
      Deliver::Setup.new.run(options)

      @tools[:deliver] = true
    end

    def default_generate_fastfile
      config = {}
      FastlaneCore::Project.detect_projects(config)
      project = FastlaneCore::Project.new(config)
      generate_fastfile(scheme: project.schemes.first)
    end

    def generate_fastfile(scheme: nil)
      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/DefaultFastfileTemplate")

      scheme = ask("Optional: The scheme name of your app (If you don't need one, just hit Enter): ").to_s.strip unless scheme
      if scheme.length > 0
        template.gsub!('[[SCHEME]]', "(scheme: \"#{scheme}\")")
      else
        template.gsub!('[[SCHEME]]', "")
      end

      template.gsub!('deliver', '# deliver') unless @tools[:deliver]
      template.gsub!('snapshot', '# snapshot') unless @tools[:snapshot]
      template.gsub!('sigh', '# sigh') unless @tools[:sigh]
      template.gsub!('xctool', '# xctool') unless @tools[:xctool]
      template.gsub!('cocoapods', '') unless @tools[:cocoapods]
      template.gsub!('carthage', '') unless @tools[:carthage]
      template.gsub!('[[FASTLANE_VERSION]]', Fastlane::VERSION)

      @tools.each do |key, value|
        Helper.log.info "'#{key}' enabled.".magenta if value
        Helper.log.info "'#{key}' not enabled.".yellow unless value
      end

      path = File.join(folder, 'Fastfile')
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your own deployment lanes.".green
    end

    def folder
      FastlaneFolder.path
    end

    def restore_previous_state
      # Move all moved files back
      files_to_copy.each do |current|
        from_path = File.join(folder, current)
        to_path = File.basename(current)
        if File.exist?(from_path)
          Helper.log.info "Moving '#{from_path}' to '#{to_path}'".yellow
          FileUtils.mv(from_path, to_path)
        end
      end

      Helper.log.info "Deleting the 'fastlane' folder".yellow
      FileUtils.rm_rf(folder)
    end
  end
end
