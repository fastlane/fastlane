
require 'fastlane_core/android_package_name_guesser'
require 'fastlane_core/ios_app_identifier_guesser'

module FastlaneCore
  class AppIdentifierGuesser
    # (optional) Returns the app identifier for the current tool
    def self.ios_app_identifier(args: nil)
      return FastlaneCore::IOSAppIdentifierGuesser.guess_app_identifier(args)
    rescue
      nil # we don't want this method to cause a crash
    end

    # (optional) Returns the app identifier for the current tool
    # supply and screengrab use different param names and env variable patterns so we have to special case here
    # example:
    #   fastlane supply --skip_upload_screenshots -a beta -p com.test.app should return com.test.app
    #   screengrab -a com.test.app should return com.test.app
    def self.android_app_identifier(args: nil, gem_name: 'fastlane')
      app_identifier = FastlaneCore::AndroidPackageNameGuesser.guess_package_name(gem_name, args)

      # Add Android prefix to prevent collisions if there is an iOS app with the same identifier
      app_identifier ? "android_project_#{app_identifier}" : nil
    rescue
      nil # we don't want this method to cause a crash
    end

    def self.app_id(args: nil, gem_name: 'fastlane')
      # check if this is an android project first because some of the same params exist for iOS and Android tools
      app_identifier = android_app_identifier(args: args, gem_name: gem_name)
      @platform = nil # since have a state in-between runs
      if app_identifier
        @platform = :android
      else
        app_identifier = ios_app_identifier(args: args)
        @platform = :ios if app_identifier
      end
      return app_identifier
    end

    # To not count the same projects multiple time for the number of launches
    # Learn more at https://github.com/fastlane/fastlane#metrics
    # Use the `FASTLANE_OPT_OUT_USAGE` variable to opt out
    # The resulting value is e.g. ce12f8371df11ef6097a83bdf2303e4357d6f5040acc4f76019489fa5deeae0d
    def self.p_hash(args: nil, gem_name: 'fastlane')
      return nil if FastlaneCore::Env.truthy?("FASTLANE_OPT_OUT_USAGE")
      require 'credentials_manager'

      app_identifier = app_id(args: args, gem_name: gem_name)

      if app_identifier
        return Digest::SHA256.hexdigest("p#{app_identifier}fastlan3_SAlt") # hashed + salted the bundle identifier
      end

      return nil
    rescue
      return nil
    end
  end
end
