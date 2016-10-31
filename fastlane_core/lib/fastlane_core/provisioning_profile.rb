module FastlaneCore
  class ProvisioningProfile
    class << self
      # @return (Hash) The hash with the data of the provisioning profile
      # @example
      #  {"AppIDName"=>"My App Name",
      #   "ApplicationIdentifierPrefix"=>["5A997XSAAA"],
      #   "CreationDate"=>#<DateTime: 2015-05-24T20:38:03+00:00 ((2457167j,74283s,0n),+0s,2299161j)>,
      #   "DeveloperCertificates"=>[#<StringIO:0x007f944b9666f8>],
      #   "Entitlements"=>
      #    {"keychain-access-groups"=>["5A997XSAAA.*"],
      #     "get-task-allow"=>false,
      #     "application-identifier"=>"5A997XAAA.net.sunapps.192",
      #     "com.apple.developer.team-identifier"=>"5A997XAAAA",
      #     "aps-environment"=>"production",
      #     "beta-reports-active"=>true},
      #   "ExpirationDate"=>#<DateTime: 2015-11-25T22:45:50+00:00 ((2457352j,81950s,0n),+0s,2299161j)>,
      #   "Name"=>"net.sunapps.192 AppStore",
      #   "TeamIdentifier"=>["5A997XSAAA"],
      #   "TeamName"=>"SunApps GmbH",
      #   "TimeToLive"=>185,
      #   "UUID"=>"1752e382-53bd-4910-a393-aaa7de0005ad",
      #   "Version"=>1}
      def parse(path)
        require 'plist'

        plist = Plist.parse_xml(`security cms -D -i "#{path}" 2> /dev/null`) # /dev/null: https://github.com/fastlane/fastlane/issues/6387
        if (plist || []).count > 5
          plist
        else
          UI.error("Error parsing provisioning profile at path '#{path}'")
          nil
        end
      end

      # @return [String] The UUID of the given provisioning profile
      def uuid(path)
        parse(path).fetch("UUID")
      end

      def profiles_path
        path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles/"
        # If the directory doesn't exist, create it first
        unless File.directory?(path)
          FileUtils.mkdir_p(path)
        end

        return path
      end

      # Installs a provisioning profile for Xcode to use
      def install(path)
        UI.message("Installing provisioning profile...")
        profile_filename = uuid(path) + ".mobileprovision"
        destination = File.join(profiles_path, profile_filename)

        if path != destination
          # copy to Xcode provisioning profile directory
          FileUtils.copy(path, destination)
          unless File.exist?(destination)
            UI.user_error!("Failed installation of provisioning profile at location: '#{destination}'")
          end
        end

        true
      end
    end
  end
end
