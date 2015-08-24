module Fastlane
  module Actions
    module SharedValues
    end

    class UpdateInfoPlistAction < Action
      def self.run(params)
        require 'plist'

        # Check if parameters are set
        if params[:app_identifier] or params[:display_name]

          # Assign folder from parameter or search for xcodeproj file
          folder = params[:xcodeproj] || Dir["*.xcodeproj"].first

          # Read existing plist file
          info_plist_path = File.join(folder, "..", params[:plist_path])
          raise "Couldn't find info plist file at path '#{params[:plist_path]}'".red unless File.exist?(info_plist_path)
          plist = Plist.parse_xml(info_plist_path)

          # Update plist values
          plist['CFBundleIdentifier'] = params[:app_identifier] if params[:app_identifier]
          plist['CFBundleDisplayName'] = params[:display_name] if params[:display_name]

          # Write changes to file
          plist_string = Plist::Emit.dump(plist)
          File.write(info_plist_path, plist_string)

          Helper.log.info "Updated #{params[:plist_path]} 💾.".green
          plist_string
        else
          Helper.log.warn("You haven't specified any parameters to update your plist.")
          false
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end

      def self.description
        'Update a Info.plist file with bundle identifier and display name'
      end

      def self.available_options
        [

          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "FL_UPDATE_PLIST_PROJECT_PATH",
                                       description: "Path to your Xcode project",
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Please pass the path to the project, not the workspace".red if value.include? "workspace"
                                         raise "Could not find Xcode project".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :plist_path,
                                       env_name: "FL_UPDATE_PLIST_PATH",
                                       description: "Path to info plist",
                                       verify_block: proc do |value|
                                         raise "Invalid plist file".red unless value[-6..-1].downcase == ".plist"
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       env_name: 'FL_UPDATE_PLIST_APP_IDENTIFIER',
                                       description: 'The App Identifier of your app',
                                       default_value: ENV['PRODUCE_APP_IDENTIFIER'],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :display_name,
                                       env_name: 'FL_UPDATE_PLIST_DISPLAY_NAME',
                                       description: 'The Display Name of your app',
                                       optional: true)
        ]
      end

      def self.author
        'tobiasstrebitzer'
      end
    end
  end
end
