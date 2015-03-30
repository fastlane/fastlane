module Fastlane
  module Actions
    module SharedValues
      IPA_OUTPUT_PATH = :IPA_OUTPUT_PATH
      DSYM_OUTPUT_PATH = :DSYM_OUTPUT_PATH
    end

    # -w, --workspace WORKSPACE Workspace (.xcworkspace) file to use to build app (automatically detected in current directory)
    # -p, --project PROJECT Project (.xcodeproj) file to use to build app (automatically detected in current directory, overridden by --workspace option, if passed)
    # -c, --configuration CONFIGURATION Configuration used to build
    # -s, --scheme SCHEME  Scheme used to build app
    # --xcconfig XCCONFIG  use an extra XCCONFIG file to build the app
    # --xcargs XCARGS      pass additional arguments to xcodebuild when building the app. Be sure to quote multiple args.
    # --[no-]clean         Clean project before building
    # --[no-]archive       Archive project after building
    # -d, --destination DESTINATION Destination. Defaults to current directory
    # -m, --embed PROVISION Sign .ipa file with .mobileprovision
    # -i, --identity IDENTITY Identity to be used along with --embed
    # --sdk SDK            use SDK as the name or path of the base SDK when building the project
    # --ipa IPA            specify the name of the .ipa file to generate (including file extension)

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
      verbose: '--verbose',
      xcargs: '--xcargs',
    }

    class IpaAction
      def self.run(params)
        # The args we will build with
        build_args = nil

        # The output directory of the IPA and dSYM
        absolute_dest_directory = nil

        params[0] ||= {} # default to hash to fill in default values

        # Allows for a whole variety of configurations
        if params.first.is_a? Hash

          # Used to get the final path of the IPA and dSYM
          if dest = params.first[:destination]
            absolute_dest_directory = Dir.glob(dest).map(&File.method(:realpath)).first
          end

          # Maps nice developer build parameters to Shenzhen args
          build_args = params_to_build_args(params.first)

        else
          build_args = params
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

        command = "ipa build #{build_args}"
        Helper.log.debug command
        Actions.sh command

        # Finds absolute path of IPA and dSYM
        absolute_ipa_path = find_ipa_file(absolute_dest_directory)
        absolute_dsym_path = find_dsym_file(absolute_dest_directory)

        # Sets shared values to use after this action is performed
        Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = absolute_ipa_path
        Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] = absolute_dsym_path
        ENV[SharedValues::IPA_OUTPUT_PATH.to_s] = absolute_ipa_path # for deliver
        ENV[SharedValues::DSYM_OUTPUT_PATH.to_s] = absolute_dsym_path
      end

      def self.params_to_build_args(params)
        # Remove nil value params unless :clean or :archive or :verbose
        params = params.delete_if { |k, v| (k != :clean && k != :archive && k != :verbose) && v.nil? }

        params = fill_in_default_values(params)

        # Maps nice developer param names to Shenzhen's `ipa build` arguments
        params.collect do |k, v|
          v ||= ''
          if args = ARGS_MAP[k]
            value = (v.to_s.length > 0 ? "\"#{v}\"" : '')
            "#{ARGS_MAP[k]} #{value}".strip
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
    end
  end
end
