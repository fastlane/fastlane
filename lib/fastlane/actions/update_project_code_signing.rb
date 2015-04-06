module Fastlane
  module Actions
    module SharedValues
    end

    class UpdateProjectCodeSigningAction

      def self.is_supported?(type)
        type == :ios
      end
      
      def self.run(params)
        path = params.first
        path = File.join(path, "project.pbxproj")
        raise "Could not find path to project config '#{path}'. Pass the path to your project (not workspace)!".red unless File.exists?(path)

        udid = (params[1] rescue nil)
        udid ||= ENV["SIGH_UDID"]

        Helper.log.info("Updating provisioning profile UDID (#{udid}) for the given project '#{path}'")

        p = File.read(path)
        File.write(path, p.gsub(/PROVISIONING_PROFILE = ".*";/, "PROVISIONING_PROFILE = \"#{udid}\";"))

        Helper.log.info("Successfully updated project settings to use UDID '#{udid}'".green)
      end
    end
  end
end
