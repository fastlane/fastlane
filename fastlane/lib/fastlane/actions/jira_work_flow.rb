module Fastlane
  module Actions
    class JiraWorkFlowAction < Action
      def self.run(params)
        # Dependency checking
        Actions.verify_gem!('jira-ruby')
        require 'jira-ruby'
        # Initialize client
        options = {
          username: params[:jira_username],
          password: params[:jira_password],
          site: params[:jira_host],
          context_path: '',
          auth_type: :basic
        }
        @client = JIRA::Client.new(options)
        UI.message("Jira issues #{params[:issue_ids]}")
        # Authorization
        params[:issue_ids].each do |issue_id|
          move_issue(issue_id, params[:jira_transition_name])
        end
      end

      def self.move_issue(issue_id, transition_name)
        # Find Issue
        issue = @client.Issue.find(issue_id)
        unless issue
          UI.message("Issue #{issue_id} not found")
          return
        end
        # Find Transition
        transitions = @client.Transition.all(issue: issue)
        transition = transitions.find { |elem| elem.name == transition_name }
        unless transition
          UI.message("Cant move issue #{issue_id} to #{transition_name}")
          return
        end
        # Perform Transition
        new_transition = issue.transitions.build
        new_transition.save!("transition" => { "id" => transition.id })
        UI.message("Moved the issue #{issue_id} to #{transition_name}")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Move jira issues to ready for test'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :issue_ids,
                                       env_name: "FL_JIRA_ISSUE_IDS",
                                       description: "An array of Issues identifiers",
                                       is_string: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("List of issues is empty, pass using `issue_ids: ['TESTISSUES-24']`") if value.size.zero?
                                       end),
          FastlaneCore::ConfigItem.new(key: :jira_username,
                                       env_name: "FL_JIRA_USERNAME",
                                       description: "Jira username",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Jira username") if value.to_s.length.zero?
                                       end),
          FastlaneCore::ConfigItem.new(key: :jira_password,
                                       env_name: "FL_JIRA_PASSWORD",
                                       description: "Jira password",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Jira password") if value.to_s.length.zero?
                                       end),
          FastlaneCore::ConfigItem.new(key: :jira_host,
                                       env_name: "FL_JIRA_HOST",
                                       description: "Jira host url",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Jira host url") if value.to_s.length.zero?
                                       end),
          FastlaneCore::ConfigItem.new(key: :jira_transition_name,
                                       env_name: "FL_JIRA_TRANSITION_NAME",
                                       description: "Transition name",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Jira Transition name, pass using `jira_transition_name: 'Close Issue'`") if value.to_s.length.zero?
                                       end)
        ]
      end

      def self.authors
        ["CognitiveDisson"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
