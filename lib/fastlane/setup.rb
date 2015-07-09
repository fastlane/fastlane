# rubocop:disable Metrics/LineLength

module Fastlane
  class Setup
    def run
      if (FastlaneFolder.setup? and not Helper.is_test?)
        Helper.log.info "Fastlane already set up at path #{folder}".yellow
        return
      end

      show_infos
      response = agree('Do you want to get started? This will move your Deliverfile and Snapfile (if they exist) (y/n)'.yellow, true)
      return unless response
      response = agree('Do you have everything commited in version control? If not please do so! (y/n)'.yellow, true)
      return unless response

      begin
        FastlaneFolder.create_folder! unless Helper.is_test?
        copy_existing_files
        generate_app_metadata
        detect_installed_tools # after copying the existing files
        ask_to_enable_other_tools
        FileUtils.mkdir(File.join(folder, 'actions'))
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
    end

    def show_infos
      Helper.log.info 'This setup will help you get up and running in no time.'.green
      Helper.log.info 'First, it will move the config files from `deliver` and `snapshot`'.green
      Helper.log.info "into the subfolder `fastlane`.\n".green
      Helper.log.info "fastlane will check what tools you're already using and set up".green
      Helper.log.info 'the tool automatically for you. Have fun! '.green
    end

    def show_analytics
      Helper.log.info "fastlane will send the number of errors for each action to"
      Helper.log.info "https://github.com/fastlane/enhancer to detect integration issues"
      Helper.log.info "No sensitive/private information will be uploaded"
      Helper.log.info("You can disable this by adding `opt_out_usage` to your Fastfile")
    end

    def files_to_copy
      ['Deliverfile', 'Snapfile', 'deliver', 'snapshot.js', 'snapshot-iPad.js', 'SnapshotHelper.js', 'screenshots']
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

    def generate_app_metadata
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
      @tools[:sigh] = false
    end

    def ask_to_enable_other_tools
      unless @tools[:deliver]
        if agree("Do you want to setup 'deliver', which is used to upload app screenshots, app metadata and app updates to the App Store or Apple TestFlight? (y/n)".yellow, true)
          Helper.log.info "Loading up 'deliver', this might take a few seconds"
          require 'deliver'
          Deliver::DeliverfileCreator.create(folder)
          @tools[:deliver] = true
        end
      else
        # deliver already enabled
        Helper.log.info '-------------------------------------------------------------------------------------------'
        Helper.log.info 'Since all files are moved into the `fastlane` subfolder, you have to adapt your Deliverfile'.yellow
        Helper.log.info 'Update your `ipa` and `beta_ipa` block of your Deliverfile to go a folder up before building'.yellow
        Helper.log.info "e.g. `system('cd ..; ipa build')`".yellow
        Helper.log.info 'Please read the above carefully and hit Enter to confirm.'.green
        STDIN.gets unless Helper.is_test?
      end

      unless @tools[:snapshot]
        if agree("Do you want to setup 'snapshot', which will help you to automatically take screenshots of your iOS app in all languages/devices? (y/n)".yellow, true)
          Helper.log.info "Loading up 'snapshot', this might take a few seconds"

          require 'snapshot' # we need both requires
          require 'snapshot/snapfile_creator'
          Snapshot::SnapfileCreator.create(folder)
          @tools[:snapshot] = true
        end
      end

      @tools[:sigh] = true if agree("Do you want to use 'sigh', which will maintain and download the provisioning profile for your app? (y/n)".yellow, true)
    end

    def generate_fastfile
      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/FastfileTemplate")

      scheme = ask("Optional: The scheme name of your app: (If you don't need one, just hit Enter.) ").to_s.strip
      if scheme.length > 0
        template.gsub!('[[SCHEME]]', "(scheme: \"#{scheme}\")")
      else
        template.gsub!('[[SCHEME]]', "")
      end


      template.gsub!('deliver', '# deliver') unless @tools[:deliver]
      template.gsub!('snapshot', '# snapshot') unless @tools[:snapshot]
      template.gsub!('sigh', '# sigh') unless @tools[:sigh]
      template.gsub!('xctool', '# xctool') unless @tools[:xctool]
      template.gsub!('cocoapods', '# cocoapods') unless @tools[:cocoapods]
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

    def tools
      @tools
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
