module FastlaneCore
  class IOSAppIdentifierGuesser
    class << self
      def guess_app_identifier_from_args(args)
        # args example: ["-a", "com.krausefx.app", "--team_id", "5AA97AAHK2"]
        args.each_with_index do |current, index|
          next unless current == "-a" || current == "--app_identifier"
          # argument names are followed by argument values in the args array;
          # use [index + 1] to find the package name (range check the array
          # to avoid array bounds errors)
          return args[index + 1] if args.count > index
        end
        nil
      end

      def guess_app_identifier_from_environment
        ["FASTLANE", "DELIVER", "PILOT", "PRODUCE", "PEM", "SIGH", "SNAPSHOT", "MATCH"].each do |current|
          return ENV["#{current}_APP_IDENTIFIER"] if FastlaneCore::Env.truthy?("#{current}_APP_IDENTIFIER")
        end
        nil
      end

      def guess_app_identifier_from_appfile
        CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
      end

      def fetch_app_identifier_from_file(file_name)
        # we only care about the app_identifier item in the configuration file, so
        # build an options array & Configuration with just that one key and it will
        # be fetched if it is present in the config file
        genericfile_options = [FastlaneCore::ConfigItem.new(key: :app_identifier)]
        options = FastlaneCore::Configuration.create(genericfile_options, {})
        # pass the empty proc to disable options validation, otherwise this will fail
        # when the other (non-app_identifier) keys are encountered in the config file;
        # 3rd parameter "true" disables the printout of the contents of the
        # configuration file, which is noisy and confusing in this case
        options.load_configuration_file(file_name, proc {}, true)
        return options.fetch(:app_identifier, ask: false)
      rescue
        # any option/file error here should just be treated as identifier not found
        nil
      end

      def guess_app_identifier_from_config_files
        ["Deliverfile", "Gymfile", "Snapfile", "Matchfile"].each do |current|
          app_identifier = self.fetch_app_identifier_from_file(current)
          return app_identifier if app_identifier
        end
        nil
      end

      # make a best-guess for the app_identifier for this project, using most-reliable signals
      #  first and then using less accurate ones afterwards; because this method only returns
      #  a GUESS for the app_identifier, it is only useful for metrics or other places where
      #  absolute accuracy is not required
      def guess_app_identifier(args)
        app_identifier = nil
        app_identifier ||= guess_app_identifier_from_args(args)
        app_identifier ||= guess_app_identifier_from_environment
        app_identifier ||= guess_app_identifier_from_appfile
        app_identifier ||= guess_app_identifier_from_config_files
        app_identifier
      end
    end
  end
end
