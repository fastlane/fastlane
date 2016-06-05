require 'plist'

module Fastlane
  module Actions
    class GoodifyInfoPlistAction < Action
      def self.run(params)
        plist = Plist::parse_xml(params[:plist])

        # default entitlement version. It rarely, if ever, needs to change.
        good_entitlement_version = params.values.fetch(:good_entitlement_version, "1.0.0.0")

        plist["GDApplicationID"] = params[:good_entitlement_id]
        plist["GDApplicationVersion"] = good_entitlement_version
        plist["GDLibraryMode"] = "GDEnterprise"

        # create a set of url schemes for GD based on app id
        app_id = plist["CFBundleIdentifier"]
        url_schemes = [
          "#{app_id}.sc",
          "#{app_id}.sc2",
          "#{app_id}.sc2.1.0.0.0",
          "com.good.gd.discovery"
        ]
        if params.values.fetch(:distribution, "appstore").downcase == "enterprise"
          url_schemes << "com.good.gd.discovery.enterprise"
        end

        # attempt to replace an existing set of GD url schemes
        replaced = false
        plist["CFBundleURLTypes"].each do |entry|
          if ( entry["CFBundleURLSchemes"].include? "com.good.gd.discovery")
            entry["CFBundleURLName"] = app_id
            entry["CFBundleURLSchemes"] = url_schemes
            replaced = true
            break
          end
        end

        if ( replaced == false)
          plist["CFBundleURLTypes"] << {
            "CFBundleURLName" => app_id,
            "CFBundleURLSchemes" => url_schemes
          }
        end
        Plist::Emit.save_plist(plist, params[:plist])
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Update the app's Info.plist to include Good Dynamics info before the build is performed"
      end

      def self.available_options
        [

            FastlaneCore::ConfigItem.new(key: :plist,
                                         env_name: "FL_GOODIFY_INFO_PLIST_FILEPATH",
                                         description: "The file path to the plist that will be compiled to the app's Info.plist for the GoodifyInfoPlistAction",
                                         verify_block: proc do |value|
                                           UI.user_error!("Invalid plist file path for GoodifyInfoPlistAction given, pass using `plist: 'path/to/plist'`") if (value.nil? || value.empty?)
                                           UI.user_error!("Non-existant plist file for GoodifyInfoPlistAction given") if (!File.exists?(value))
                                         end),

           FastlaneCore::ConfigItem.new(key: :good_entitlement_version,
                                       env_name: "FL_GOODIFY_INFO_PLIST_ENTITLEMENT_VERSION",
                                       description: "The Good app version number for the GoodifyInfoPlistAction",
                                       verify_block: proc do |value|
                                         pattern = Regexp.new('^(:?[1-9]\d{0,2})(:?\.(:?0|[1-9]\d{0,2})){0,3}$')
                                         did_match = !pattern.match(value).nil?
                                         UI.user_error!("Invalid Good app version for GoodifyInfoPlistAction given, pass using `good_entitlement_version: '1.2.3.4'`") if (value and (value.empty? || !did_match))
                                       end,
                                       optional: true,
                                       default_value: "1.0.0.0"),

          FastlaneCore::ConfigItem.new(key: :good_entitlement_id,
                                       env_name: "FL_GOODIFY_INFO_PLIST_ENTITLEMENT_ID",
                                       description: "The Good ID for the GoodifyInfoPlistAction",
                                       verify_block: proc do |value|
                                         UI.user_error!("No Good ID for GoodifyInfoPlistAction given, pass using `good_entitlement_id: 'com.example.good'`") if (value and value.empty?)
                                         UI.user_error!("Good ID must be 35 characters or fewer in order to work with Windows Phones") if value.length > 35
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end), # the default value if the user didn't provide one

           FastlaneCore::ConfigItem.new(key: :distribution,
                                        env_name: "FL_GOODIFY_INFO_PLIST_DISTRIBUTION_TARGET",
                                        description: "The distribution target, \"appstore\" or \"enterprise\", for the GoodifyInfoPlistAction",
                                        verify_block: proc do |value|
                                          UI.user_error!("Invalid distribution target given for GoodifyInfoPlistAction given, pass using `good_entitlement_id: 'appstore' or 'enterprise'`") if (value and value.empty? or !["appstore", "enterprise"].include?(value))
                                        end,
                                        default_value: "enterprise") # the default value if the user didn't provide one
        ]
      end

      def self.authors
        ["lyndsey-ferguson/ldferguson"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
