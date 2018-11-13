# rubocop:disable Lint/AssignmentInCondition
module Fastlane
  module Actions
    ARGS_MAP = {
      workspace: '-w',
      project: '-p',
      configuration: '-c',
      scheme: '-s',
      clean: '--clean',
      archive: '--archive',
      destination: '-d',
      embed: '-m',
      identity: '-i',
      sdk: '--sdk',
      ipa: '--ipa',
      xcconfig: '--xcconfig',
      xcargs: '--xcargs'
    }

    class IpaAction < Action
      def self.is_supported?(platform)
        platform == :ios
      end

      def self.run(params)
        Actions.verify_gem!('krausefx-shenzhen')

        # The output directory of the IPA and dSYM
        absolute_dest_directory = nil

        # Used to get the final path of the IPA and dSYM
        if dest = params[:destination]
          absolute_dest_directory = File.expand_path(dest)
        end

        # The args we will build with
        # Maps nice developer build parameters to Shenzhen args
        build_args = params_to_build_args(params)

        unless params[:scheme]
          UI.important("You haven't specified a scheme. This might cause problems. If you can't see any output, please pass a `scheme`")
        end

        # If no dest directory given, default to current directory
        absolute_dest_directory ||= Dir.pwd

        if Helper.test?
          Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = File.join(absolute_dest_directory, 'test.ipa')
          Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] = File.join(absolute_dest_directory, 'test.app.dSYM.zip')
          return build_args
        end

        # Joins args into space delimited string
        build_args = build_args.join(' ')

        core_command = "krausefx-ipa build #{build_args} --verbose | xcpretty"
        command = "set -o pipefail && #{core_command}"
        UI.verbose(command)

        begin
          Actions.sh(command)

          # Finds absolute path of IPA and dSYM
          absolute_ipa_path = find_ipa_file(absolute_dest_directory)
          absolute_dsym_path = find_dsym_file(absolute_dest_directory)

          # Sets shared values to use after this action is performed
          Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = absolute_ipa_path
          Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] = absolute_dsym_path
          ENV[SharedValues::IPA_OUTPUT_PATH.to_s] = absolute_ipa_path # for deliver
          ENV[SharedValues::DSYM_OUTPUT_PATH.to_s] = absolute_dsym_path

          deprecation_warning
        rescue => ex
          [
            "-------------------------------------------------------",
            "Original Error:",
            " => " + ex.to_s,
            "A build error occurred. You are using legacy `shenzhen` for building",
            "it is recommended to upgrade to _gym_: ",
            "https://docs.fastlane.tools/actions/gym/",
            core_command,
            "-------------------------------------------------------"
          ].each do |txt|
            UI.error(txt)
          end

          # Raise a custom exception, as the the normal one is useless for the user
          UI.user_error!("A build error occurred, this is usually related to code signing. Take a look at the error above")
        end
      end

      def self.params_to_build_args(config)
        params = config.values

        params = params.delete_if { |k, v| v.nil? }
        params = fill_in_default_values(params)

        # Maps nice developer param names to Shenzhen's `ipa build` arguments
        params.collect do |k, v|
          v ||= ''
          if ARGS_MAP[k]
            if k == :clean
              v == true ? '--clean' : '--no-clean'
            elsif k == :archive
              v == true ? '--archive' : '--no-archive'
            else
              value = (v.to_s.length > 0 ? "\"#{v}\"" : '')
              "#{ARGS_MAP[k]} #{value}".strip
            end
          end
        end.compact
      end

      def self.fill_in_default_values(params)
        embed = Actions.lane_context[Actions::SharedValues::SIGH_PROFILE_PATH] || ENV["SIGH_PROFILE_PATH"]
        params[:embed] ||= embed if embed
        params
      end

      def self.find_ipa_file(dir)
        # Finds last modified .ipa in the destination directory
        Dir[File.join(dir, '*.ipa')].sort { |a, b| File.mtime(b) <=> File.mtime(a) }.first
      end

      def self.find_dsym_file(dir)
        # Finds last modified .dSYM.zip in the destination directory
        Dir[File.join(dir, '*.dSYM.zip')].sort { |a, b| File.mtime(b) <=> File.mtime(a) }.first
      end

      def self.description
        "Easily build and sign your app using shenzhen"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :workspace,
                                       env_name: "IPA_WORKSPACE",
                                       description: "WORKSPACE Workspace (.xcworkspace) file to use to build app (automatically detected in current directory)",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: "IPA_PROJECT",
                                       description: "Project (.xcodeproj) file to use to build app (automatically detected in current directory, overridden by --workspace option, if passed)",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: "IPA_CONFIGURATION",
                                       description: "Configuration used to build",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: "IPA_SCHEME",
                                       description: "Scheme used to build app",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :clean,
                                       env_name: "IPA_CLEAN",
                                       description: "Clean project before building",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :archive,
                                       env_name: "IPA_ARCHIVE",
                                       description: "Archive project after building",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :destination,
                                       env_name: "IPA_DESTINATION",
                                       description: "Build destination. Defaults to current directory",
                                       default_value_dynamic: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :embed,
                                       env_name: "IPA_EMBED",
                                       description: "Sign .ipa file with .mobileprovision",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :identity,
                                       env_name: "IPA_IDENTITY",
                                       description: "Identity to be used along with --embed",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :sdk,
                                       env_name: "IPA_SDK",
                                       description: "Use SDK as the name or path of the base SDK when building the project",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "IPA_IPA",
                                       description: "Specify the name of the .ipa file to generate (including file extension)",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :xcconfig,
                                       env_name: "IPA_XCCONFIG",
                                       description: "Use an extra XCCONFIG file to build the app",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :xcargs,
                                       env_name: "IPA_XCARGS",
                                       description: "Pass additional arguments to xcodebuild when building the app. Be sure to quote multiple args",
                                       optional: true,
                                       type: :shell_string)
        ]
      end

      def self.output
        [
          ['IPA_OUTPUT_PATH', 'The path to the newly generated ipa file'],
          ['DSYM_OUTPUT_PATH', 'The path to the dsym file']
        ]
      end

      def self.author
        "joshdholtz"
      end

      def self.example_code
        [
          'ipa(
            workspace: "MyApp.xcworkspace",
            configuration: "Debug",
            scheme: "MyApp",
            # (optionals)
            clean: true,                     # This means "Do Clean". Cleans project before building (the default if not specified).
            destination: "path/to/dir",      # Destination directory. Defaults to current directory.
            ipa: "my-app.ipa",               # specify the name of the .ipa file to generate (including file extension)
            xcargs: "MY_ADHOC=0",            # pass additional arguments to xcodebuild when building the app.
            embed: "my.mobileprovision",     # Sign .ipa file with .mobileprovision
            identity: "MyIdentity",          # Identity to be used along with --embed
            sdk: "10.0",                     # use SDK as the name or path of the base SDK when building the project.
            archive: true                    # this means "Do Archive". Archive project after building (the default if not specified).
          )'
        ]
      end

      def self.category
        :deprecated
      end

      def self.deprecated_notes
        [
          "You are using legacy `shenzhen` to build your app, which will be removed soon!",
          "It is recommended to upgrade to _gym_.",
          "To do so, just replace `ipa(...)` with `gym(...)` in your Fastfile.",
          "To make code signing work, follow [https://docs.fastlane.tools/codesigning/xcode-project/](https://docs.fastlane.tools/codesigning/xcode-project/)."
        ].join("\n")
      end
    end
  end
end
# rubocop:enable Lint/AssignmentInCondition
