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
      response = agree('Do you have everything commited in version control? If not please do so now! (y/n)'.yellow, true)
      return unless response

      # rubocop:disable Lint/RescueException
      begin
        FastlaneFolder.create_folder! unless Helper.is_test?
        copy_existing_files
        generate_appfile
        detect_installed_tools # after copying the existing files
        ask_to_enable_other_tools
        FileUtils.mkdir(File.join(FastlaneFolder.path, 'actions'))
        generate_fastfile
        show_analytics
        Helper.log.info 'Successfully finished setting up fastlane'.green
      rescue Exception => ex # this will also be caused by Ctrl + C
        # Something went wrong with the setup, clear the folder again
        # and restore previous files
        Helper.log.fatal 'Error occurred with the setup program! Reverting changes now!'.red
        restore_previous_state
        raise ex
      end
      # rubocop:enable Lint/RescueException
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

    def generate_appfile
      Helper.log.info '------------------------------'
      Helper.log.info 'To not re-enter your username and app identifier every time you run one of the fastlane tools or fastlane, these will be stored from now on.'.green

      app_identifier = ask('App Identifier (com.krausefx.app): '.yellow)
      apple_id = ask('Your Apple ID (fastlane@krausefx.com): '.yellow)

      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/AppfileTemplate")
      template.gsub!('[[APP_IDENTIFIER]]', app_identifier)
      template.gsub!('[[APPLE_ID]]', apple_id)
      path = File.join(folder, 'Appfile')
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your preferred app metadata information.".green
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

    def ask_to_enable_other_tools
      if @tools[:deliver] # deliver already enabled
        Helper.log.info 'Since all files are moved into the `fastlane` subfolder, you have to adapt your Deliverfile'.yellow
      else
        if agree("Do you want to setup 'deliver', which is used to upload app screenshots, app metadata and app updates to the App Store? This requires the app to be in the App Store already. (y/n)".yellow, true)
          Helper.log.info "Loading up 'deliver', this might take a few seconds"
          require 'deliver'
          require 'deliver/setup'
          options = FastlaneCore::Configuration.create(Deliver::Options.available_options, {})
          Deliver::Runner.new(options) # to login...
          Deliver::Setup.new.run(options)

          @tools[:deliver] = true
        end
      end

      unless @tools[:snapshot]
        if Helper.mac? and agree("Do you want to setup 'snapshot', which will help you to automatically take screenshots of your iOS app in all languages/devices? (y/n)".yellow, true)
          Helper.log.info "Loading up 'snapshot', this might take a few seconds"

          require 'snapshot'
          require 'snapshot/setup'
          Snapshot::Setup.create(folder)

          @tools[:snapshot] = true
        end
      end

      @tools[:sigh] = true if agree("Do you want to use 'sigh', which will maintain and download the provisioning profile for your app? (y/n)".yellow, true)
    end

    def generate_fastfile
      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/FastfileTemplate")

      scheme = ask("Optional: The scheme name of your app (If you don't need one, just hit Enter): ").to_s.strip
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
