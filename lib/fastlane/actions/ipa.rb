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
      ipa: '--ipa'
    }

    class IpaAction
      def self.run(params)
        
        # The args we will build with
        build_args = nil

        # The output path of the IPA
        absolute_ipa_path = nil

        # Allows for a whole variety of configurations
        if params.first.is_a? Hash
          destination = params.first[:destination]
          build_args = params_to_build_args(params.first)
        else
          build_args = params
        end

        build_args = build_args.join(' ')

        Actions.sh "ipa build #{build_args}"
        
        absolute_ipa_path ||= find_ipa_file
        absolute_ipa_path = File.join(Dir.pwd, absolute_ipa_path)
        absolute_dsym_path = File.join(Dir.pwd, find_dsym_file)

        Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = absolute_ipa_path
        Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] = absolute_dsym_path
      end

      def self.params_to_build_args(params)
        # Remove nil value params unless :clean or :archive
        params = params.delete_if { |k, v| (k != :clean && k != :archive ) && v.nil? }

        # Maps nice developer param names to Shenzhen's `ipa build` arguments
        params.collect do |k,v|
          v ||= ''
          if args = ARGS_MAP[k]
           "#{ARGS_MAP[k]} #{v}".strip
          end
        end.compact
      end

      def self.find_ipa_file
        Dir["*"].sort { |a,b| File.mtime(a) <=> File.mtime(b) }.find { |f| f.end_with? ".ipa"}
      end

      def self.find_dsym_file
        Dir["*"].sort { |a,b| File.mtime(a) <=> File.mtime(b) }.find { |f| f.end_with? ".dSYM.zip"}
      end

    end

  end
end