module Fastlane
  module Actions
    class RunInSimulatorAction < Action
      def self.run(params)
        Helper.log.info "Running in iOS Simulator".green

        commands = [] # for testing only

        # find matching device/s
        result = matching_device_lines(params)
        commands << result # for testing only

        device_lines = result.split("\n")

        selected_device_line = selected_device_line_from_device_lines(device_lines)
        commands << selected_device_line # for testing only

        # parsing the device line from shell command into device object with properties
        selected_device = device_object_from_device_line(selected_device_line)

        Helper.log.info "Using device #{selected_device_line}".green

        # building or using .app file
        app_file_path = params[:app_file_path]
        unless app_file_path
          app_file_path, build_artifacts_path = build_app(params, selected_device)
        end

        Helper.log.info "Using .app file from #{app_file_path}".green

        # kill currently running simulator (if)
        result = kill_simulator
        commands << result # for testing only

        # starting / booting simulator device
        result = boot_simulator(selected_device)
        commands << result # for testing only

        # we don't know when Simulator is up, so we just sleep for a while until it is. awful
        sleep(7)

        # installing app
        result = install_app(selected_device, app_file_path)
        commands << result # for testing only

        # launching app
        result = launch_app(params[:scheme], selected_device)
        commands << result # for testing only

        # clean artifc
        clean(params, selected_device, build_artifacts_path) if params[:clean]

        Helper.log.info "App running in simulator, enjoy!".green

        commands
      end

      def self.matching_device_lines(params)
        device_name = params[:device_name]
        device_id = params[:device_id]
        ios_version = params[:ios_version]
        command = "xcrun instruments -s devices | grep -v 'Known Devices:'"
        if device_name
          command += " | grep '#{device_name}"
          command += params[:exact_device_name] ? " ('" : "'"
        end
        command += " | grep '#{device_id}'" if device_id
        command += " | grep '#{ios_version}'" if ios_version
        return Actions.sh(
          command,
          log: false
        )
      end

      def self.kill_simulator
        Helper.log.info "Killing currently (if) running simulator".green
        begin
          return Actions.sh(
            "killall Simulator",
            log: false
          )
        rescue

        end
      end

      # boot simulator with given device
      def self.boot_simulator(device)
        Helper.log.info "Starting simulator...".green
        return Actions.sh(
          "open -a Simulator --args -CurrentDeviceUDID #{device[:device_id]}",
          # "xcrun simctl boot #{selected_device[:device_id]}", # this option won't work
          log: false
        )
      end

      # install app on device
      def self.install_app(device, app_file_path)
        Helper.log.info "Installing app...".green
        return Actions.sh(
          "xcrun simctl install #{device[:device_id]} #{app_file_path}",
          log: false
        )
      end

      # launches the app with given scheme and selected device
      def self.launch_app(scheme, device)
        Helper.log.info "Launching app...".green
        bundle_identifier = bundle_identifier(scheme)
        return Actions.sh(
          "xcrun simctl launch #{device[:device_id]} #{bundle_identifier}",
          log: false
        )
      end

      # returns a final selected device line by receiving matching device lines
      def self.selected_device_line_from_device_lines(device_lines)
        selected_device_line = nil
        case device_lines.count
        when 0 # no matching device, so show a full list of devices
          Helper.log.info "Could not find matching device".yellow
          selected_device_line = show_and_let_user_select
        when 1 # one exact match, so use it
          selected_device_line = device_lines.first
        else # ambiguous match, so let user select
          Helper.log.info "Ambiguous device match".yellow
          selected_device_line = let_user_select_from_list(device_lines)
        end
        return selected_device_line
      end

      # presents the user with a full available device list
      def self.show_and_let_user_select
        device_lines = Actions.sh(
          "xcrun instruments -s devices | grep -v 'Known Devices:'",
          log: false
        ).split("\n")
        return let_user_select_from_list(device_lines)
      end

      # presents the user with a device list made of given device lines
      def self.let_user_select_from_list(device_lines)
        return device_lines.first if Helper.is_test?

        device_lines_with_index = []
        device_lines.each_with_index {|device_line, index| device_lines_with_index << "#{index + 1}. #{device_line}" }
        user_selection = PromptAction.run(
          text: "\n\nPlease select device from the following list:\n  #{device_lines_with_index.join("\n  ")}\n".yellow
        ).to_i

        return device_lines[user_selection - 1]
      end

      # parses shell output line into device object with properties
      def self.device_object_from_device_line(device_line)
        device = {}
        device[:device_name] = device_line.split(' (').first
        device[:ios_version] = device_line[/\((.*?)\)/, 1]
        device[:device_id] = device_line[/\[(.*?)\]/, 1]
        return device
      end

      # builds the app with given params
      def self.build_app(params, device)
        Helper.log.info "Building app...".green

        build_params = build_params_from_params(params, device)
        build_params[:build] = true
        XcodebuildAction.run(
          build_params
        )

        scheme = params[:scheme]
        build_artifacts_path = params[:build_artifacts_path]

        app_filename = build_settings_value_for_key(scheme, "FULL_PRODUCT_NAME")
        app_file_path = "./#{build_artifacts_path}/Build/Products/Debug-iphonesimulator/#{app_filename}"

        return app_file_path, build_artifacts_path
      end

      # creates a build params from given config params
      def self.build_params_from_params(params, device)
        # xcodebuild related params
        build_params = {}
        build_params[:workspace] = params[:workspace] if params[:workspace]
        build_params[:project] = params[:project] if params[:project]
        build_params[:scheme] = params[:scheme] if params[:scheme]
        build_params[:derivedDataPath] = params[:build_artifacts_path]
        build_params[:sdk] = "iphonesimulator#{device[:ios_version]}"
        build_params[:destination] = "platform=iOS Simulator,name=#{device[:device_name]},OS=#{device[:ios_version]}"

        return build_params
      end

      # gets a value for given key in Xcode build settings
      def self.build_settings_value_for_key(scheme, key)
        return Actions.sh(
          "xcodebuild -showBuildSettings -scheme #{scheme} | grep #{key}",
          log: false
        ).split(" = ").last
      end

      # gets app bundle identifier from scheme
      def self.bundle_identifier(scheme)
        return build_settings_value_for_key(scheme, "PRODUCT_BUNDLE_IDENTIFIER")
      end

      # cleans build artifacts
      def self.clean(params, device, build_artifacts_path)
        build_params = build_params_from_params(params, device)
        XccleanAction.run(build_params)
        FileUtils.rm_rf(build_artifacts_path) unless Helper.is_test?
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Runs an Xcode project or workspace in iOS Simulator"
      end

      def self.details
        "Takes Xcode project or workspace, builds it and runs the product in iOS simulator. Where optional arguments are not provided, an interactive menu promts the user to select options."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: 'FL_RS_SCHEME',
                                       description: 'Scheme name to launch',
                                       optional: false,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :workspace,
                                       env_name: 'FL_RS_WORKSPACE',
                                       description: 'Workspace to use',
                                       optional: true,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: 'FL_RS_PROJECT',
                                       description: 'Project to use',
                                       optional: true,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :app_file_path,
                                       env_name: 'FL_RS_APP_FILE_PATH',
                                       description: 'The .app filename to use to run (must be built with the correct settings)',
                                       optional: true,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :clean,
                                       env_name: 'FL_RS_CLEAN',
                                       description: 'Cleaning artifacts after building/launching',
                                       optional: true,
                                       is_string: false,
                                       default_value: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :build_artifacts_path,
                                       env_name: 'FL_RS_BUILD_ARTIFACTS_PATH',
                                       description: 'Build artifacts path, defaults to run_in_simulator_build (remember to add to .gitignore)',
                                       optional: true,
                                       is_string: true,
                                       default_value: 'run_in_simulator_build'
                                      ),
          FastlaneCore::ConfigItem.new(key: :device_name,
                                       env_name: 'FL_RS_DEVICE_NAME',
                                       description: "Device name to run the app on (e.g. 'iPhone 5s'). This will be used to match an available device",
                                       optional: true,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :device_id,
                                       env_name: 'FL_RS_DEVICE_ID',
                                       description: 'Device id to run the apo on (e.g. some UDID). This will be used to match an available device',
                                       optional: true,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :ios_version,
                                       env_name: 'FL_RS_IOS_VERSION',
                                       description: "iOS version to run the app in (e.g. '9.2'). This will be used to match an available device",
                                       optional: true,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :exact_device_name,
                                       env_name: 'FL_RS_EXACT_DEVICE_NAME',
                                       description: "Set this false if you want device_name to be not matched exactly (i.e. passing 'iPhone 5' will match both 'iPhone 5' and 'iPhone 5s')",
                                       optional: true,
                                       is_string: false,
                                       default_value: true
                                      )
        ]
      end

      def self.author
        ['7mllm7']
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
