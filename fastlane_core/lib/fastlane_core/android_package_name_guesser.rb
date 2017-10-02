module FastlaneCore
  class AndroidPackageNameGuesser
    class << self
      def android_package_name_arg?(gem_name, arg)
        return arg == "--package_name" ||
               arg == "--app_package_name" ||
               (arg == '-p' && gem_name == 'supply') ||
               (arg == '-a' && gem_name == 'screengrab')
      end

      def guess_package_name_from_args(gem_name, args)
        # args example: ["-a", "com.krausefx.app"]
        package_name = nil
        args.each_with_index do |current, index|
          if android_package_name_arg?(gem_name, current)
            package_name = args[index + 1] if args.count > index
            break
          end
        end
        package_name
      end

      def guess_package_name_from_environment
        package_name = nil
        package_name ||= ENV["SUPPLY_PACKAGE_NAME"] if FastlaneCore::Env.truthy?("SUPPLY_PACKAGE_NAME")
        package_name ||= ENV["SCREENGRAB_APP_PACKAGE_NAME"] if FastlaneCore::Env.truthy?("SCREENGRAB_APP_PACKAGE_NAME")
        package_name
      end

      def guess_package_name_from_appfile
        CredentialsManager::AppfileConfig.try_fetch_value(:package_name)
      end

      def fetch_package_name_from_file(file_name, package_name_key)
        genericfile_options = [FastlaneCore::ConfigItem.new(key: package_name_key)]
        options = FastlaneCore::Configuration.create(genericfile_options, {})
        options.load_configuration_file(file_name, proc {}, true)
        return options[package_name_key]
      rescue
        # any option/file error here should just be treated as identifier not found
        nil
      end

      def guess_package_name_from_config_files
        package_name = nil
        package_name ||= fetch_package_name_from_file("Supplyfile", :package_name)
        package_name ||= fetch_package_name_from_file("Screengrabfile", :app_package_name)
        package_name
      end

      # make a best-guess for the package_name for this project, using most-reliable signals
      #  first and then using less accurate ones afterwards; because this method only returns
      #  a GUESS for the package_name, it is only useful for metrics or other places where
      #  absolute accuracy is not required
      def guess_package_name(gem_name, args)
        package_name = nil
        package_name ||= guess_package_name_from_args(gem_name, args)
        package_name ||= guess_package_name_from_environment
        package_name ||= guess_package_name_from_appfile
        package_name ||= guess_package_name_from_config_files
        package_name
      end
    end
  end
end
