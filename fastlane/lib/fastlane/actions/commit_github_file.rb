module Fastlane
  module Actions
    module SharedValues
      COMMIT_GITHUB_FILE_HTML_LINK = :COMMIT_GITHUB_FILE_HTML_LINK
      COMMIT_GITHUB_FILE_SHA = :COMMIT_GITHUB_FILE_SHA
      COMMIT_GITHUB_FILE_JSON = :COMMIT_GITHUB_FILE_JSON
    end

    class CommitGithubFileAction < Action
      def self.run(params)
        repo_name = params[:repository_name]
        branch = params[:branch] ||= 'master'
        commit_message = params[:message]

        file_path = params[:path]
        file_name = File.basename(file_path)
        expanded_file_path = File.expand_path(file_path)

        UI.important("Creating commit on #{repo_name} on branch \"#{branch}\" for file \"#{file_path}\"")

        api_file_path = file_path
        api_file_path = "/#{api_file_path}" unless api_file_path.start_with?('/')
        api_file_path = api_file_path[0..-2] if api_file_path.end_with?('/')

        payload = {
          path: api_file_path,
          message: commit_message || "Updated : #{file_name}",
          content: Base64.encode64(File.open(expanded_file_path).read),
          branch: branch
        }

        UI.message("Committing #{api_file_path}")
        GithubApiAction.run({
          server_url: params[:server_url],
          api_token: params[:api_token],
          api_bearer: params[:api_bearer],
          secure: params[:secure],
          http_method: "PUT",
          path: File.join("repos", params[:repository_name], "contents", api_file_path),
          body: payload,
          error_handlers: {
            422 => proc do |result|
              json = result[:json]
              UI.error(json || result[:body])
              error = if json['message'] == "Invalid request.\n\n\"sha\" wasn't supplied."
                        "File already exists - please remove from repo before uploading or rename this upload"
                      else
                        "Unprocessable error"
                      end
              UI.user_error!(error)
            end
          }
        }) do |result|
          UI.success("Successfully committed file to GitHub")
          json = result[:json]
          html_url = json['commit']['html_url']
          download_url = json['content']['download_url']
          commit_sha = json['commit']['sha']

          UI.important("Commit: \"#{html_url}\"")
          UI.important("SHA: \"#{commit_sha}\"")
          UI.important("Download at: \"#{download_url}\"")

          Actions.lane_context[SharedValues::COMMIT_GITHUB_FILE_HTML_LINK] = html_url
          Actions.lane_context[SharedValues::COMMIT_GITHUB_FILE_SHA] = commit_sha
          Actions.lane_context[SharedValues::COMMIT_GITHUB_FILE_JSON] = json
        end

        Actions.lane_context[SharedValues::COMMIT_GITHUB_FILE_JSON]
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This will commit a file directly on GitHub via the API"
      end

      def self.details
        [
          "Commits a file directly to GitHub. You must provide your GitHub Personal token (get one from [https://github.com/settings/tokens/new](https://github.com/settings/tokens/new)), the repository name and the relative file path from the root git project.",
          "Out parameters provide the commit sha created, which can be used for later usage for examples such as releases, the direct download link and the full response JSON.",
          "Documentation: [https://developer.github.com/v3/repos/contents/#create-a-file](https://developer.github.com/v3/repos/contents/#create-a-file)."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repository_name,
                                       env_name: "FL_COMMIT_GITHUB_FILE_REPOSITORY_NAME",
                                       description: "The path to your repo, e.g. 'fastlane/fastlane'",
                                       verify_block: proc do |value|
                                         UI.user_error!("Please only pass the path, e.g. 'fastlane/fastlane'") if value.include?("github.com")
                                         UI.user_error!("Please only pass the path, e.g. 'fastlane/fastlane'") if value.split('/').count != 2
                                       end),
          FastlaneCore::ConfigItem.new(key: :server_url,
                                       env_name: "FL_COMMIT_GITHUB_FILE_SERVER_URL",
                                       description: "The server url. e.g. 'https://your.internal.github.host/api/v3' (Default: 'https://api.github.com')",
                                       default_value: "https://api.github.com",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please include the protocol in the server url, e.g. https://your.github.server/api/v3") unless value.include?("//")
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_COMMIT_GITHUB_FILE_API_TOKEN",
                                       description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                       conflicting_options: [:api_bearer],
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       default_value: ENV["GITHUB_API_TOKEN"],
                                       default_value_dynamic: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :api_bearer,
                                       env_name: "FL_COMMIT_GITHUB_FILE_API_BEARER",
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       description: "Use a Bearer authorization token. Usually generated by GitHub Apps, e.g. GitHub Actions GITHUB_TOKEN environment variable",
                                       conflicting_options: [:api_token],
                                       optional: true,
                                       default_value: nil),
          FastlaneCore::ConfigItem.new(key: :branch,
                                       env_name: "FL_COMMIT_GITHUB_FILE_BRANCH",
                                       description: "The branch that the file should be committed on (default: master)",
                                       default_value: 'master',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: 'FL_COMMIT_GITHUB_FILE_PATH',
                                       description: 'The relative path to your file from project root e.g. assets/my_app.xcarchive',
                                       optional: false,
                                       verify_block: proc do |value|
                                         value = File.expand_path(value)
                                         UI.user_error!("File not found at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_COMMIT_GITHUB_FILE_MESSAGE",
                                       description: "The commit message. Defaults to the file name",
                                       default_value_dynamic: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :secure,
                                       env_name: "FL_COMMIT_GITHUB_FILE_SECURE",
                                       description: "Optionally disable secure requests (ssl_verify_peer)",
                                       type: Boolean,
                                       default_value: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['COMMIT_GITHUB_FILE_HTML_LINK', 'Link to your committed file'],
          ['COMMIT_GITHUB_FILE_SHA', 'Commit SHA generated'],
          ['COMMIT_GITHUB_FILE_JSON', 'The whole commit JSON object response']
        ]
      end

      def self.return_type
        :hash_of_strings
      end

      def self.return_value
        [
          "A hash containing all relevant information for this commit",
          "Access things like 'html_url', 'sha', 'message'"
        ].join("\n")
      end

      def self.authors
        ["tommeier"]
      end

      def self.example_code
        [
          'response = commit_github_file(
            repository_name: "fastlane/fastlane",
            server_url: "https://api.github.com",
            api_token: ENV["GITHUB_TOKEN"],
            message: "Add my new file",
            branch: "master",
            path: "assets/my_new_file.xcarchive"
          )'
        ]
      end

      def self.is_supported?(platform)
        true
      end

      def self.category
        :source_control
      end
    end
  end
end
