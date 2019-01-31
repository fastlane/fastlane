module Fastlane
  module Actions
    module SharedValues
    end

    class UpdateProjectTeamAction < Action
      def self.run(params)
        project_path = params[:path]
        target_name = params[:target]

        UI.user_error!("Could not find path to xcodeproj '#{project_path}'. Pass the path to your project (not workspace)!") unless File.exist?(project_path)

        # Load .xcodeproj
        project = Xcodeproj::Project.open(project_path)

        # Fetch target
        targets = project.native_targets
        if params[:target]
          targets.select! { |native_target| native_target.name == target_name }
        end
        targets.each do |target|
          UI.user_error!("Could not find target `#{target_name}` in the project `#{project_path}`") if target.nil?

          UI.message("Updating development team (#{params[:teamid]}) for target `#{target_name}` in the project '#{project_path}'")
          # Update the build settings
          target.build_configurations.each do |configuration|
            configuration.build_settings['DEVELOPMENT_TEAM'] = params[:teamid]
          end

          project.save

          UI.success("Successfully updated project settings to use Developer Team ID '#{params[:teamid]}' for target `#{target_name}`")
        end
      end

      def self.description
        "Update Xcode Development Team ID"
      end

      def self.details
        "This action updates the Developer Team ID of your Xcode project."
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
          FastlaneCore::ConfigItem.new(key: :target,
                                       env_name: "FL_PROJECT_TARGET",
                                       description: "Name of the target you want to update",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :teamid,
                                       env_name: "FL_PROJECT_TEAM_ID",
                                       description: "The Team ID you want to use",
                                       code_gen_sensitive: true,
                                       default_value: ENV["TEAM_ID"] || CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                       default_value_dynamic: true)
        ]
      end

      def self.author
        "lgaches"
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
