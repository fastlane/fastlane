module Fastlane
  module Actions
    module SharedValues
    end

    class UpdateProjectTeamAction < Action
      def self.run(params)
        project_path = params[:path]
        selected_targets = params[:targets]

        # Load .xcodeproj
        project = Fastlane::Helper::XcodeprojHelper.get_project!(project_path)

        # Fetch target
        targets = project.native_targets
        if selected_targets
          # Error to user if invalid target
          diff_targets = selected_targets - targets.map(&:name)
          UI.user_error!("Could not find target(s) in the project '#{project_path}' - #{diff_targets.join(',')}") unless diff_targets.empty?

          targets.select! { |native_target| selected_targets.include?(native_target.name) }
        end

        # Set teamid in target
        targets.each do |target|
          target.build_configurations.each do |configuration|
            # Iterate over any keys that start with DEVELOPMENT_TEAM
            # This will also set keys that have filtering like [sdk=iphoneos*]
            keys = configuration.build_settings.keys.select { |key| key.to_s.start_with?("DEVELOPMENT_TEAM") }
            keys.each do |key|
              configuration.build_settings[key] = params[:teamid]
              UI.message("Updated build setting '#{key}' to '#{params[:teamid]}' for configuration '#{configuration.name}'")
            end

            # Explicitly set the key with value if keys don't exist
            unless keys.include?('DEVELOPMENT_TEAM')
              configuration.build_settings['DEVELOPMENT_TEAM'] = params[:teamid]
              UI.message("Added build setting 'DEVELOPMENT_TEAM' with value '#{params[:teamid]}' for configuration '#{configuration.name}'")
            end
          end

          project.save

          UI.success("Successfully updated project settings to use Developer Team ID '#{params[:teamid]}' for target `#{target.name}`")
        end
      end

      def self.description
        "Update Xcode Development Team ID"
      end

      def self.details
        "This action updates (or adds) the Developer Team ID of your Xcode project."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_PROJECT_SIGNING_PROJECT_PATH",
                                       description: "Path to your Xcode project",
                                       default_value: Dir['*.xcodeproj'].first,
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Path is invalid") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :targets,
                                       env_name: "FL_PROJECT_TARGET",
                                       description: "Name of the targets you want to update",
                                       type: Array,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :teamid,
                                       env_name: "FL_PROJECT_TEAM_ID",
                                       description: "The Team ID you want to use",
                                       code_gen_sensitive: true,
                                       default_value: ENV["TEAM_ID"] || CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                       default_value_dynamic: true)
        ]
      end

      def self.authors
        ["lgaches", "iBotPeaches"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'update_project_team',
          'update_project_team(
            path: "Example.xcodeproj",
            teamid: "A3ZZVJ7CNY"
          )'
        ]
      end

      def self.category
        :project
      end
    end
  end
end
