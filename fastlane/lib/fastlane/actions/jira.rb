module Fastlane
  module Actions
    class JiraAction < Action
      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        require 'jira-ruby'

        site         = params[:url]
        auth_type    = :basic
        context_path = params[:context_path]
        username     = params[:username]
        password     = params[:password]
        ticket_id    = params[:ticket_id]
        comment_text = params[:comment_text]

        options = {
                    site: site,
                    context_path: context_path,
                    auth_type: auth_type,
                    username: username,
                    password: password
                  }

        client = JIRA::Client.new(options)
        issue = client.Issue.find(ticket_id)
        comment = issue.comments.build
        comment.save({ 'body' => comment_text })
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Leave a comment on JIRA tickets"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                      env_name: "FL_JIRA_SITE",
                                      description: "URL for Jira instance",
                                       verify_block: proc do |value|
                                         UI.user_error!("No url for Jira given, pass using `url: 'url'`") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :context_path,
                                      env_name: "FL_JIRA_CONTEXT_PATH",
                                      description: "Appends to the url (ex: \"/jira\")",
                                      optional: true,
                                      default_value: ""),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_JIRA_USERNAME",
                                       description: "Username for JIRA instance",
                                       verify_block: proc do |value|
                                         UI.user_error!("No username") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_JIRA_PASSWORD",
                                       description: "Password for Jira",
                                       sensitive: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No password") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :ticket_id,
                                       env_name: "FL_JIRA_TICKET_ID",
                                       description: "Ticket ID for Jira, i.e. IOS-123",
                                       verify_block: proc do |value|
                                         UI.user_error!("No Ticket specified") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :comment_text,
                                       env_name: "FL_JIRA_COMMENT_TEXT",
                                       description: "Text to add to the ticket as a comment",
                                       verify_block: proc do |value|
                                         UI.user_error!("No comment specified") if value.to_s.length == 0
                                       end)
        ]
      end

      def self.return_value
      end

      def self.authors
        ["iAmChrisTruman"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'jira(
            url: "https://bugs.yourdomain.com",
            username: "Your username",
            password: "Your password",
            ticket_id: "Ticket ID, i.e. IOS-123",
            comment_text: "Text to post as a comment"
          )',
          'jira(
            url: "https://yourserverdomain.com",
            context_path: "/jira",
            username: "Your username",
            password: "Your password",
            ticket_id: "Ticket ID, i.e. IOS-123",
            comment_text: "Text to post as a comment"
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
