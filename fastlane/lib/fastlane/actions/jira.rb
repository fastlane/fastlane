module Fastlane
  module Actions
    module SharedValues
      JIRA_JSON = :JIRA_JSON
    end

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

        begin
          client = JIRA::Client.new(options)
          issue = client.Issue.find(ticket_id)
          comment = issue.comments.build
          comment.save({ 'body' => comment_text })

          # An exact representation of the JSON returned from the JIRA API
          # https://github.com/sumoheavy/jira-ruby/blob/master/lib/jira/base.rb#L67
          json_response = comment.attrs
          raise 'Failed to add a comment on Jira ticket' if json_response.nil?

          Actions.lane_context[SharedValues::JIRA_JSON] = json_response
          UI.success('Successfully added a comment on Jira ticket')
          return json_response
        rescue => exception
          message = "Received exception when adding a Jira comment: #{exception}"
          if params[:fail_on_error]
            UI.user_error!(message)
          else
            UI.error(message)
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Leave a comment on a Jira ticket"
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
                                       description: "Username for Jira instance",
                                       verify_block: proc do |value|
                                         UI.user_error!("No username") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_JIRA_PASSWORD",
                                       description: "Password or API token for Jira",
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
                                       end),
          FastlaneCore::ConfigItem.new(key: :fail_on_error,
                                       env_name: "FL_JIRA_FAIL_ON_ERROR",
                                       description: "Should an error adding the Jira comment cause a failure?",
                                       type: Boolean,
                                       optional: true,
                                       default_value: true) # Default value is true for 'Backward compatibility'
        ]
      end

      def self.output
        [
          ['JIRA_JSON', 'The whole Jira API JSON object']
        ]
      end

      def self.return_value
        [
          "A hash containing all relevant information of the Jira comment",
          "Access Jira comment 'id', 'author', 'body', and more"
        ].join("\n")
      end

      def self.return_type
        :hash
      end

      def self.authors
        ["iAmChrisTruman", "crazymanish"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'jira(
            url: "https://bugs.yourdomain.com",
            username: "Your username",
            password: "Your password or API token",
            ticket_id: "IOS-123",
            comment_text: "Text to post as a comment"
          )', # How to get API token: https://developer.atlassian.com/cloud/jira/platform/basic-auth-for-rest-apis/#get-an-api-token
          'jira(
            url: "https://yourserverdomain.com",
            context_path: "/jira",
            username: "Your username",
            password: "Your password or API token",
            ticket_id: "IOS-123",
            comment_text: "Text to post as a comment"
          )',
          'jira(
            ticket_id: "IOS-123",
            comment_text: "Text to post as a comment",
            fail_on_error: false
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
