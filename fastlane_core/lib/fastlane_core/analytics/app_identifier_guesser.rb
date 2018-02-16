require_relative '../android_package_name_guesser'
require_relative '../ios_app_identifier_guesser'
require_relative '../env'

module FastlaneCore
  class AppIdentifierGuesser
    attr_accessor :args
    attr_accessor :gem_name
    attr_accessor :platform
    attr_accessor :p_hash
    attr_accessor :app_id

    def initialize(args: nil, gem_name: 'fastlane')
      @args = args
      @gem_name = gem_name

      @app_id = android_app_identifier(args, gem_name)
      @platform = nil # since have a state in-between runs
      if @app_id
        @platform = :android
      else
        @app_id = ios_app_identifier(args)
        @platform = :ios if @app_id
      end

      @p_hash = generate_p_hash(@app_id)
    end

    # To not count the same projects multiple time for the number of launches
    # Learn more at https://docs.fastlane.tools/#metrics
    # Use the `FASTLANE_OPT_OUT_USAGE` variable to opt out
    # The resulting value is e.g. ce12f8371df11ef6097a83bdf2303e4357d6f5040acc4f76019489fa5deeae0d
    def generate_p_hash(app_id)
      unless !FastlaneCore::Env.truthy?("FASTLANE_OPT_OUT_USAGE") && !app_id.nil?
        return nil
      end

      return Digest::SHA256.hexdigest("p#{app_id}fastlan3_SAlt") # hashed + salted the bundle identifier
    rescue
      return nil # we don't want this method to cause a crash
    end

    # (optional) Returns the app identifier for the current tool
    def ios_app_identifier(args)
      return FastlaneCore::IOSAppIdentifierGuesser.guess_app_identifier(args)
    rescue
      nil # we don't want this method to cause a crash
    end

    # (optional) Returns the app identifier for the current tool
    # supply and screengrab use different param names and env variable patterns so we have to special case here
    # example:
    #   fastlane supply --skip_upload_screenshots -a beta -p com.test.app should return com.test.app
    #   screengrab -a com.test.app should return com.test.app
    def android_app_identifier(args, gem_name)
      app_identifier = FastlaneCore::AndroidPackageNameGuesser.guess_package_name(gem_name, args)

      # Add Android prefix to prevent collisions if there is an iOS app with the same identifier
      app_identifier ? "android_project_#{app_identifier}" : nil
    rescue
      nil # we don't want this method to cause a crash
    end
  end
end
