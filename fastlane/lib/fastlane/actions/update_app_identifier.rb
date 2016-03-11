module Fastlane
  module Actions
    class UpdateAppIdentifierAction < Action
      def self.run(params)
        require 'plist'
        require 'xcodeproj'

        info_plist_key = 'INFOPLIST_FILE'
        identifier_key = 'PRODUCT_BUNDLE_IDENTIFIER'

        # Read existing plist file
        info_plist_path = File.join(params[:xcodeproj], '..', params[:plist_path])
        raise "Couldn't find info plist file at path '#{params[:plist_path]}'".red unless File.exist?(info_plist_path)
        plist = Plist.parse_xml(info_plist_path)

        # Check if current app identifier product bundle identifier
        if plist['CFBundleIdentifier'] == "$(#{identifier_key})"
          # Load .xcodeproj
          project_path = params[:xcodeproj]
          project = Xcodeproj::Project.open(project_path)

          # Fetch the build configuration objects
          configs = project.objects.select { |obj| obj.isa == 'XCBuildConfiguration' && !obj.build_settings[identifier_key].nil? }
          raise "Info plist uses $(#{identifier_key}), but xcodeproj does not".red unless configs.count > 0

          configs = configs.select { |obj| obj.build_settings[info_plist_key] == params[:plist_path] }
          raise "Xcodeproj doesn't have configuration with info plist #{params[:plist_path]}.".red unless configs.count > 0

          # For each of the build configurations, set app identifier
          configs.each do |c|
            c.build_settings[identifier_key] = params[:app_identifier]
          end

          # Write changes to the file
          project.save

          Helper.log.info "Updated #{params[:xcodeproj]} 💾.".green
        else
          # Update plist value
          plist['CFBundleIdentifier'] = params[:app_identifier]

          # Write changes to file
          plist_string = Plist::Emit.dump(plist)
          File.write(info_plist_path, plist_string)

          Helper.log.info "Updated #{params[:plist_path]} 💾.".green
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end

      def self.description
        "Update the project's bundle identifier"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "FL_UPDATE_APP_IDENTIFIER_PROJECT_PATH",
                                       description: "Path to your Xcode project",
                                       default_value: Dir['*.xcodeproj'].first,
                                       verify_block: proc do |value|
                                         raise "Please pass the path to the project, not the workspace".red if value.include? "workspace"
                                         raise "Could not find Xcode project".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :plist_path,
                                       env_name: "FL_UPDATE_APP_IDENTIFIER_PLIST_PATH",
                                       description: "Path to info plist, relative to your Xcode project",
                                       verify_block: proc do |value|
                                         raise "Invalid plist file".red unless value[-6..-1].casecmp(".plist").zero?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       env_name: 'FL_UPDATE_APP_IDENTIFIER',
                                       description: 'The app Identifier you want to set',
                                       default_value: ENV['PRODUCE_APP_IDENTIFIER'])
        ]
      end

      def self.authors
        ['squarefrog', 'tobiasstrebitzer']
      end
    end
  end
end
