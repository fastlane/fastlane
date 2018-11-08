module Fastlane
  module Actions
    class RequestReviewersAction < Action
      def self.run(params)
        number = params[:number]
        UI.message("Requesting reviewers for pull request ##{params[:number]}")

        GithubApiAction.run(
          server_url: params[:api_url],
          api_token: params[:api_token],
          http_method: 'POST',
          path: "repos/#{params[:repo]}/pulls/#{params[:number]}/requested_reviewers",
          body: {
            'reviewers' => params[:reviewers],
            'team_reviewers' => params[:team_reviewers]
          },
          error_handlers: {
            '*' => proc do |result|
              UI.error("GitHub responded with #{result[:status]}: #{result[:body]}")
              return nil
            end
          }
        ) do |result|
          json = result[:json]
          number = json['number']
          html_url = json['html_url']
          UI.success("Successfully requested reviewers for pull request ##{number}")

          Actions.lane_context[SharedValues::CREATE_PULL_REQUEST_HTML_URL] = html_url
          return html_url
        end
      end

      def self.default_repo
        uri = Actions.lane_context[SharedValues::CREATE_PULL_REQUEST_HTML_URL]
        return nil if uri.nil?
        URI.parse(uri).path.split('/').reverse.slice(2, 2).reverse.join('/')
      end

      def self.default_number
        uri = Actions.lane_context[SharedValues::CREATE_PULL_REQUEST_HTML_URL]
        return nil if uri.nil?
        URI.parse(uri).path.split('/').last.to_i
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This will request reviewers for a given pull request on GitHub"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "GITHUB_PULL_REQUEST_API_TOKEN",
                                       description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       default_value: ENV["GITHUB_API_TOKEN"],
                                       default_value_dynamic: true,
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repo,
                                       env_name: "GITHUB_PULL_REQUEST_REPO",
                                       description: "The name of the repository for which the pull request was sent",
                                       default_value: default_repo,
                                       default_value_dynamic: true,
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :number,
                                       env_name: "GITHUB_PULL_REQUEST_NUMBER",
                                       description: "The pull request number (defaults to the result of `create_pull_request` action)",
                                       default_value: default_number,
                                       default_value_dynamic: true,
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :reviewers,
                                       env_name: "GITHUB_PULL_REQUEST_REVIEWERS",
                                       description: "An array of user logins that will be requested",
                                       default_value: [],
                                       type: Array,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :team_reviewers,
                                       env_name: "GITHUB_PULL_REQUEST_TEAM_REVIEWERS",
                                       description: "An array of team slugs that will be requested",
                                       default_value: [],
                                       type: Array,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :api_url,
                                       env_name: "GITHUB_PULL_REQUEST_API_URL",
                                       description: "The URL of GitHub API - used when the Enterprise (default to `https://api.github.com`)",
                                       is_string: true,
                                       code_gen_default_value: 'https://api.github.com',
                                       default_value: 'https://api.github.com',
                                       optional: true)
        ]
      end

      def self.author
        ["leoformaggio"]
      end

      def self.is_supported?(platform)
        return true
      end

      def self.return_value
        "The parsed JSON when successful"
      end

      def self.example_code
        [
          'request_reviewers(
            team_reviewers: ["justice-league"]
          )',
          'request_reviewers(
            repo: "fastlane/fastlane",
            number: 42,
            reviewers: ["octocat", "hubot"]
          )'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
