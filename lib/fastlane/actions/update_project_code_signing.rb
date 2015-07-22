module Fastlane
  module Actions
    module SharedValues
    end

    class UpdateProjectCodeSigningAction < Action
      def self.run(params)
        path = params[:path]
        path = File.join(path, "project.pbxproj")
        raise "Could not find path to project config '#{path}'. Pass the path to your project (not workspace)!".red unless File.exists?(path)

        Helper.log.info("Updating provisioning profile UDID (#{params[:udid]}) for the given project '#{path}'")

        p = File.read(path)
        File.write(path, p.gsub(/PROVISIONING_PROFILE = ".*";/, "PROVISIONING_PROFILE = \"#{params[:udid]}\";"))

        Helper.log.info("Successfully updated project settings to use UDID '#{params[:udid]}'".green)
      end

      def self.description
        "Updated code signing settings from 'Automatic' to a specific profile"
      end

      def self.details
        "This feature is not yet 100% finished"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_PROJECT_SIGNING_PROJECT_PATH",
                                       description: "Path to your Xcode project",
                                       verify_block: Proc.new do |value|
                                        raise "Path is invalid".red unless File.exists?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :udid,
                                       env_name: "FL_PROJECT_SIGNING_UDID",
                                       description: "The UDID of the provisioning profile you want to use",
                                       default_value: ENV["SIGH_UDID"])
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
