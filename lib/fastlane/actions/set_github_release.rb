module Fastlane
  module Actions
    module SharedValues
      SET_GITHUB_RELEASE_HTML_LINK = :SET_GITHUB_RELEASE_HTML_LINK
      SET_GITHUB_RELEASE_RELEASE_ID = :SET_GITHUB_RELEASE_RELEASE_ID
      SET_GITHUB_RELEASE_JSON = :SET_GITHUB_RELEASE_JSON
    end

    class SetGithubReleaseAction < Action
      def self.run(params)

        Helper.log.info "Creating release of #{params[:repository_name]} on tag \"#{params[:tag_name]}\" with name \"#{params[:name]}\".".yellow

        require 'json'
        body = {
          'tag_name' => params[:tag_name],
          'target_commitish' => params[:commitish],
          'name' => params[:name],
          'body' => params[:description],
          'draft' => params[:is_draft],
          'prerelease' => params[:is_prerelease]
        }.to_json

        require 'excon'
        require 'base64'
        headers = { 'User-Agent' => 'fastlane-set_github_release' }
        headers['Authorization'] = "Basic #{Base64.strict_encode64(params[:api_token])}" if params[:api_token]
        response = Excon.post("https://api.github.com/repos/#{params[:repository_name]}/releases", 
          :headers => headers,
          :body => body
          )

        case response[:status]
        when 201
          Helper.log.info "Successfully created release at tag \"#{params[:tag_name]}\" on GitHub!".green
          body = JSON.parse(response.body)
          html_url = body['html_url']
          release_id = body['id']
          Helper.log.info "See release at \"#{html_url}\"".yellow
          Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_HTML_LINK] = html_url
          Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_RELEASE_ID] = release_id
          Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_JSON] = body
          return body
        when 422
          Helper.log.error "Release on tag #{params[:tag_name]} already exists!".red
        when 404
          raise "Repository #{params[:repository_name]} cannot be found, please double check its name and that you provided a valid API token (if it's a private repository).".red
        when 401
          raise "You are not authorized to access #{params[:repository_name]}, please make sure you provided a valid API token.".red
        else
          if response[:status] != 200
            Helper.log.error "GitHub responded with #{response[:status]}:#{response[:body]}".red
          end
        end
        return nil
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This will create a new release on GitHub from given metadata"
      end

      def self.details
        "Creates a new release on GitHub. You must provide your GitHub Personal token 
        (get one from https://github.com/settings/tokens/new), the repository name
        and tag name. If the tag doesn't exist, one will be created on the commit or branch passed-in as
        commitish. Out parameters provide the release's id, which can be used for later editing and the 
        release html link to GitHub."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repository_name,
                                       env_name: "FL_SET_GITHUB_RELEASE_REPOSITORY_NAME",
                                       description: "The path to your repo, e.g. 'KrauseFx/fastlane'",
                                       verify_block: Proc.new do |value|
                                          raise "Please only pass the path, e.g. 'KrauseFx/fastlane'".red if value.include?"github.com"
                                          raise "Please only pass the path, e.g. 'KrauseFx/fastlane'".red if value.split('/').count != 2
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_GITHUB_RELEASE_API_TOKEN",
                                       description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :tag_name,
                                       env_name: "FL_SET_GITHUB_RELEASE_TAG_NAME",
                                       description: "Pass in the tag name",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "FL_SET_GITHUB_RELEASE_NAME",
                                       description: "Name of this release",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :commitish,
                                       env_name: "FL_SET_GITHUB_RELEASE_COMMITISH",
                                       description: "If provided tag doesn't exist, a new one will be created on the provided branch/commit",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :description,
                                       env_name: "FL_SET_GITHUB_RELEASE_DESCRIPTION",
                                       description: "Description of this release",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :is_draft,
                                       env_name: "FL_SET_GITHUB_RELEASE_IS_DRAFT",
                                       description: "Whether the release should be marked as draft",
                                       optional: true,
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :is_prerelease,
                                       env_name: "FL_SET_GITHUB_RELEASE_IS_PRERELEASE",
                                       description: "Whether the release should be marked as prerelease",
                                       optional: true,
                                       default_value: false,
                                       is_string: false)
        ]
      end

      def self.output
        [
          ['SET_GITHUB_RELEASE_HTML_LINK', 'Link to your created release'],
          ['SET_GITHUB_RELEASE_RELEASE_ID', 'Release id (useful for subsequent editing)'],
          ['SET_GITHUB_RELEASE_JSON', 'The whole release JSON object']
        ]
      end

      def self.authors
        ["czechboy0"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end