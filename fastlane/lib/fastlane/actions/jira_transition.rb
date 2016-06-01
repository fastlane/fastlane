module Fastlane
  module Actions
    class JiraTransitionAction < Action

      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        require 'jira'

        site          = params[:url]
        context_path  = ""
        auth_type     = :basic
        username      = params[:username]
        password      = params[:password]
        project_key   = params[:project_key]
        transition_id = params[:transition_id]
        comment_text  = params[:comment]

        options = {
                    site: site,
                    context_path: context_path,
                    auth_type: auth_type,
                    username: username,
                    password: password
                  }

        client = JIRA::Client.new(options)

        if Actions.lane_context[SharedValues::FL_CHANGELOG].nil?
          changelog_configuration = FastlaneCore::Configuration.create(Actions::ChangelogFromGitCommitsAction.available_options, {})
          Actions::ChangelogFromGitCommitsAction.run(changelog_configuration)
        end

        issue_ids = Actions.lane_context[SharedValues::FL_CHANGELOG].scan(/#{project_key}-\d+/i).uniq

        issue_ids.each do |issue_id|
          begin
            issue = client.Issue.find(issue_id)
            transition = issue.transitions.build
            transition.save!("transition" => { "id" => transition_id })

            if !comment_text.nil?
              comment = issue.comments.build
              comment.save({"body" => comment_text})
            end
          rescue Exception => e
            "Skipping issue #{issue_id}"
          end
        end
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
                                       env_name: "FL_JIRA_TRANSITION_PROJECT_KEY",
                                       description: "Project Key for Jira, i.e. IOS",
                                       verify_block: proc do |value|
                                         UI.user_error!("No Project Key specified") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :transition_id,
                                       env_name: "FL_JIRA_TRANSITION_TRANSITION_ID",
                                       description: "Transition to apply to the tickets referenced in the changelog",
                                       verify_block: proc do |value|
                                         UI.user_error!("No transition id specified") if value.to_s.length == 0
                                       end),
        FastlaneCore::ConfigItem.new(key: :comment,
                                     env_name: "FL_JIRA_TRANSITION_COMMENT",
                                     description: "Comment to add if the transition is applied",
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("No transition id specified") if value.to_s.length == 0
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
