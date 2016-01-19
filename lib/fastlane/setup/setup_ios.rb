module Fastlane
  class SetupIos < Setup
    # the tools that are already enabled
    attr_accessor :tools
    attr_accessor :project
    attr_accessor :apple_id

    attr_accessor :portal_ref
    attr_accessor :itc_ref

    attr_accessor :dev_portal_team
    attr_accessor :itc_team

    attr_accessor :app_identifier
    attr_accessor :app_name

    def run
      if FastlaneFolder.setup? and !Helper.is_test?
        Helper.log.info "Fastlane already set up at path #{folder}".yellow
        return
      end

      show_infos

      # rubocop:disable Lint/RescueException
      begin
        FastlaneFolder.create_folder! unless Helper.is_test?
        setup_project
        ask_for_apple_id
        detect_if_app_is_available
        print_config_table

        if UI.confirm("Please confirm the above values")
          copy_existing_files
          generate_appfile
          detect_installed_tools # after copying the existing files
          create_app_if_necessary
          enable_deliver
          FileUtils.mkdir(File.join(FastlaneFolder.path, 'actions'))
          generate_fastfile
          show_analytics
        else
          UI.user_error!("Setup cancelled by user")
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

    def setup_project
      config = {}
      FastlaneCore::Project.detect_projects(config)
      self.project = FastlaneCore::Project.new(config)
      self.app_identifier = self.project.default_app_identifier # These two vars need to be accessed in order to be set
      self.app_name = self.project.default_app_name # They are set as a side effect, this could/should be changed down the road
    end

    def print_config_table
      rows = []
      rows << ["Apple ID", self.apple_id]
      rows << ["App Name", self.app_name]
      rows << ["App Identifier", self.app_identifier]
      rows << [(self.project.is_workspace ? "Workspace" : "Project"), self.project.path]
      require 'terminal-table'
      puts ""
      puts Terminal::Table.new(rows: rows, title: "Detected Values")
      puts ""

      unless self.itc_ref
        UI.important "This app identifier doesn't exist on iTunes Connect yet, it will be created for you"
      end

      unless self.portal_ref
        UI.important "This app identifier doesn't exist on the Apple Developer Portal yet, it will be created for you"
      end
    end

    def show_infos
      Helper.log.info 'This setup will help you get up and running in no time.'.green
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

    def ask_for_apple_id
      self.apple_id = ask('Your Apple ID (e.g. fastlane@krausefx.com): '.yellow)
    end

    def generate_appfile
      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/AppfileTemplate")
      template.gsub!('[[APP_IDENTIFIER]]', self.app_identifier)
      template.gsub!('[[APPLE_ID]]', self.apple_id)
      template.gsub!('[[DEV_PORTAL_TEAM_ID]]', self.dev_portal_team)
      if self.itc_team
        template.gsub!('[[ITC_TEAM]]', "itc_team_id \"#{self.itc_team}\" # iTunes Connect Team ID\n")
      else
        template.gsub!('[[ITC_TEAM]]', "")
      end
      path = File.join(folder, 'Appfile')
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your preferred app metadata information.".green
    end

    # Detect if the app was created on the Dev Portal / iTC
    def detect_if_app_is_available
      require 'spaceship'

      UI.important "Verifying if app is available on the Apple Developer Portal and iTunes Connect..."
      UI.message "Starting login with user '#{self.apple_id}'"
      Spaceship.login(self.apple_id, nil)
      self.dev_portal_team = Spaceship.select_team # TODO: add self.dev_portal_team to the Appfile
      self.portal_ref = Spaceship::App.find(self.app_identifier)
      
      Spaceship::Tunes.login(@apple_id, nil)
      self.itc_team = Spaceship::Tunes.select_team
      self.itc_ref = Spaceship::Application.find(self.app_identifier)
    end

    def create_app_if_necessary
      UI.important "Creating the app on iTunes Connect and the Apple Developer Portal"
      require 'produce'
      config = {} # this has to be done like this
      FastlaneCore::Project.detect_projects(config)
      project = FastlaneCore::Project.new(config)

      produce_options_hash = {
        app_name: project.app_name,
        app_identifier: self.app_identifier
      }
      Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, produce_options_hash)
      begin
        ENV['PRODUCE_APPLE_ID'] = Produce::Manager.start_producing
      rescue => exception
        if exception.to_s.include?("The App Name you entered has already been used")
          Helper.log.info "It looks like that #{project.app_name} has already been taken by someone else, please enter an alternative.".yellow
          Produce.config[:app_name] = ask("App Name: ".yellow)
          Produce.config[:skip_devcenter] = true # since we failed on iTC
          ENV['PRODUCE_APPLE_ID'] = Produce::Manager.start_producing
        end
      end
    end

    def detect_installed_tools
      self.tools = {}
      self.tools[:snapshot] = File.exist?(File.join(folder, 'Snapfile'))
      self.tools[:cocoapods] = File.exist?(File.join(File.expand_path('..', folder), 'Podfile'))
      self.tools[:carthage] = File.exist?(File.join(File.expand_path('..', folder), 'Cartfile'))
    end

    def enable_deliver
      Helper.log.info "Loading up 'deliver', this might take a few seconds"
      require 'deliver'
      require 'deliver/setup'
      options = FastlaneCore::Configuration.create(Deliver::Options.available_options, {})
      Deliver::Runner.new(options) # to login...
      Deliver::Setup.new.run(options)
    end

    def generate_fastfile
      scheme = self.project.schemes.first
      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/DefaultFastfileTemplate")

      scheme = ask("Optional: The scheme name of your app (If you don't need one, just hit Enter): ").to_s.strip unless scheme
      if scheme.length > 0
        template.gsub!('[[SCHEME]]', "(scheme: \"#{scheme}\")")
      else
        template.gsub!('[[SCHEME]]', "")
      end

      template.gsub!('snapshot', '# snapshot') unless self.tools[:snapshot]
      template.gsub!('cocoapods', '') unless self.tools[:cocoapods]
      template.gsub!('carthage', '') unless self.tools[:carthage]
      template.gsub!('[[FASTLANE_VERSION]]', Fastlane::VERSION)

      self.tools.each do |key, value|
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
