module Fastlane
  module Actions
    module SharedValues
    end

    class UpdateInfoPlistAction < Action
      def self.run(params)
        require 'xcodeproj'

        # Check if parameters are set
        if params[:app_identifier] or params[:display_name] or params[:block]
          if (params[:app_identifier] or params[:display_name]) and params[:block]
            UI.important("block parameter can not be specified with app_identifier or display_name")
            return false
          end

          # Assign folder from parameter or search for xcodeproj file
          folder = params[:xcodeproj] || Dir["*.xcodeproj"].first

          if params[:scheme]
            project = Xcodeproj::Project.open(folder)
            scheme = project.native_targets.detect { |target| target.name == params[:scheme] }
            UI.user_error!("Couldn't find scheme named '#{params[:scheme]}'") unless scheme

            params[:plist_path] = scheme.build_configurations.first.build_settings["INFOPLIST_FILE"]
            UI.user_error!("Scheme named '#{params[:scheme]}' doesn't have a plist file") unless params[:plist_path]
            params[:plist_path] = params[:plist_path].gsub("$(SRCROOT)", ".")
          end

          if params[:plist_path].nil?
            UI.user_error!("You must specify either a plist path or a scheme")
          end

          # Read existing plist file
          info_plist_path = File.join(folder, "..", params[:plist_path])
          UI.user_error!("Couldn't find info plist file at path '#{info_plist_path}'") unless File.exist?(info_plist_path)
          plist = Xcodeproj::Plist.read_from_path(info_plist_path)

          # Update plist values
          plist['CFBundleIdentifier'] = params[:app_identifier] if params[:app_identifier]
          plist['CFBundleDisplayName'] = params[:display_name] if params[:display_name]
          params[:block].call(plist) if params[:block]

          # Write changes to file
          Xcodeproj::Plist.write_to_path(plist, info_plist_path)

          UI.success("Updated #{params[:plist_path]} 💾.")
          File.read(info_plist_path)
        else
          UI.important("You haven't specified any parameters to update your plist.")
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

      def self.details
        "This action allows you to modify your `Info.plist` file before building. This may be useful if you want a separate build for alpha, beta or nightly builds, but don't want a separate target."
      end

      def self.available_options
        [

          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "FL_UPDATE_PLIST_PROJECT_PATH",
                                       description: "Path to your Xcode project",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with?(".xcworkspace")
                                         UI.user_error!("Could not find Xcode project") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :plist_path,
                                       env_name: "FL_UPDATE_PLIST_PATH",
                                       description: "Path to info plist",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid plist file") unless value[-6..-1].casecmp(".plist").zero?
                                       end),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: "FL_UPDATE_PLIST_APP_SCHEME",
                                       description: "Scheme of info plist",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       env_name: 'FL_UPDATE_PLIST_APP_IDENTIFIER',
                                       description: 'The App Identifier of your app',
                                       code_gen_sensitive: true,
                                       default_value: ENV['PRODUCE_APP_IDENTIFIER'],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :display_name,
                                       env_name: 'FL_UPDATE_PLIST_DISPLAY_NAME',
                                       description: 'The Display Name of your app',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :block,
                                       is_string: false,
                                       description: 'A block to process plist with custom logic',
                                       optional: true)

        ]
      end

      def self.author
        'tobiasstrebitzer'
      end

      def self.example_code
        [
          'update_info_plist( # update app identifier string
            plist_path: "path/to/Info.plist",
            app_identifier: "com.example.newappidentifier"
          )',
          'update_info_plist( # Change the Display Name of your app
            plist_path: "path/to/Info.plist",
            display_name: "MyApp-Beta"
          )',
          'update_info_plist( # Target a specific `xcodeproj` rather than finding the first available one
            xcodeproj: "path/to/Example.proj",
            plist_path: "path/to/Info.plist",
            display_name: "MyApp-Beta"
          )',
          'update_info_plist( # Advanced processing: find URL scheme for particular key and replace value
            xcodeproj: "path/to/Example.proj",
            plist_path: "path/to/Info.plist",
            block: lambda { |plist|
              urlScheme = plist["CFBundleURLTypes"].find{|scheme| scheme["CFBundleURLName"] == "com.acme.default-url-handler"}
              urlScheme[:CFBundleURLSchemes] = ["acme-production"]
            }
          )'
        ]
      end

      def self.category
        :project
      end
    end
  end
end
