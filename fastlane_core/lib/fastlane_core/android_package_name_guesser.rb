require 'credentials_manager/appfile_config'

require_relative 'configuration/configuration'
require_relative 'env'

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
          next unless android_package_name_arg?(gem_name, current)
          # argument names are followed by argument values in the args array;
          # use [index + 1] to find the package name (range check the array
          # to avoid array bounds errors)
          package_name = args[index + 1] if args.count > index
          break
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
        # we only care about the package name item in the configuration file, so
        # build an options array & Configuration with just that one key and it will
        # be fetched if it is present in the config file
        genericfile_options = [FastlaneCore::ConfigItem.new(key: package_name_key)]
        options = FastlaneCore::Configuration.create(genericfile_options, {})
        # pass the empty proc to disable options validation, otherwise this will fail
        # when the other (non-package name) keys are encountered in the config file;
        # 3rd parameter "true" disables the printout of the contents of the
        # configuration file, which is noisy and confusing in this case
        options.load_configuration_file(file_name, proc {}, true)
        return options.fetch(package_name_key, ask: false)
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
