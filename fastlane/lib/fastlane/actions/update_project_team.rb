module Fastlane
  module Actions
    module SharedValues
    end

    class UpdateProjectTeamAction < Action
      def self.run(params)
        project_path = params[:path]
        selected_targets = params[:targets]

        UI.user_error!("Could not find path to xcodeproj '#{project_path}'. Pass the path to your project (not workspace)!") unless File.exist?(project_path)

        # Load .xcodeproj
        project = Xcodeproj::Project.open(project_path)

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
          UI.message("Updating development team (#{params[:teamid]}) for target `#{target.name}` in the project '#{project_path}'")
          # Update the build settings
          target.build_configurations.each do |configuration|
            configuration.build_settings['DEVELOPMENT_TEAM'] = params[:teamid]
          end

          project.save

          UI.success("Successfully updated project settings to use Developer Team ID '#{params[:teamid]}' for target `#{target.name}`")
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
