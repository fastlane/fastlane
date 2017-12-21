module Fastlane
  module Actions
    module SharedValues
    end

    class UpdateProjectCodeSigningAction < Action
      def self.run(params)
        UI.message("You shouldn't use update_project_code_signing")
        UI.message("Have you considered using the recommended way to do code signing?")
        UI.message("https://docs.fastlane.tools/codesigning/getting-started/")

        path = params[:path]
        path = File.join(path, "project.pbxproj")
        UI.user_error!("Could not find path to project config '#{path}'. Pass the path to your project (not workspace)!") unless File.exist?(path)

        uuid = params[:uuid] || params[:udid]
        UI.message("Updating provisioning profile UUID (#{uuid}) for the given project '#{path}'")

        p = File.read(path)
        File.write(path, p.gsub(/PROVISIONING_PROFILE = ".*";/, "PROVISIONING_PROFILE = \"#{uuid}\";"))

        UI.success("Successfully updated project settings to use UUID '#{uuid}'")
      end

      def self.description
        "Updated code signing settings from 'Automatic' to a specific profile"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_PROJECT_SIGNING_PROJECT_PATH",
                                       description: "Path to your Xcode project",
                                       verify_block: proc do |value|
                                         UI.user_error!("Path is invalid") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :udid,
                                       env_name: "FL_PROJECT_SIGNING_UDID",
                                       description: "DEPRECATED: see :uuid",
                                       code_gen_sensitive: true,
                                       default_value: ENV["SIGH_UUID"]),
          FastlaneCore::ConfigItem.new(key: :uuid,
                                       env_name: "FL_PROJECT_SIGNING_UUID",
                                       description: "The UUID of the provisioning profile you want to use",
                                       code_gen_sensitive: true,
                                       default_value: ENV["SIGH_UUID"])
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        []
      end

      def self.category
        :deprecated
      end

      def self.deprecated_notes
        "You shouldn't use update_project_code_signing.\n" \
          "Have you considered using the recommended way to do code signing?\n" \
          "https://docs.fastlane.tools/codesigning/getting-started/"
      end
    end
  end
end
