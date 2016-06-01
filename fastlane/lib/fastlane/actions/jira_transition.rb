module Fastlane
  module Actions
    class JiraTransitionAction < Action

      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        require 'jira'

        site         = params[:url]
        context_path = ""
        auth_type    = :basic
        username     = params[:username]
        password     = params[:password]
        project_key  = params[:project_key]
        transition   = params[:transition]

        options = {
                    site: site,
                    context_path: context_path,
                    auth_type: auth_type,
                    username: username,
                    password: password
                  }

        client = JIRA::Client.new(options)
        project = client.Project.find(project_key)
        puts Actions.lane_context[SharedValues::FL_CHANGELOG]
        #issue = client.Issue.find(ticket_id)
        #comment = issue.comments.build
        #comment.save({ 'body' => comment_text })
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Applies the defined JIRA transition to all the tickets mentioned in the changelog."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                      env_name: "FL_JIRA_SITE",
                                      description: "URL for Jira instance",
                                       verify_block: proc do |value|
                                         UI.user_error!("No url for Jira given, pass using `url: 'url'`") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_JIRA_USERNAME",
                                       description: "Username for JIRA instance",
                                       verify_block: proc do |value|
                                         UI.user_error!("No username") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_JIRA_PASSWORD",
                                       description: "Password for Jira",
                                       verify_block: proc do |value|
                                         UI.user_error!("No password") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :project_key,
                                       env_name: "FL_JIRA_PROJECT_KEY",
                                       description: "Project Key for Jira, i.e. IOS",
                                       verify_block: proc do |value|
                                         UI.user_error!("No Project Key specified") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :transition,
                                       env_name: "FL_JIRA_TRANSITION",
                                       description: "Transition to apply to the tickets referenced in the changelog",
                                       verify_block: proc do |value|
                                         UI.user_error!("No transition specified") if value.to_s.length == 0
                                       end)
        ]
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["Valerio Mazzeo", "Tiziano Bruni"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
