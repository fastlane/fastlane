# rubocop:disable Metrics/AbcSize

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
        Helper.log.info "Will also upload assets #{params[:upload_assets]}.".yellow if params[:upload_assets]

        require 'json'
        body_obj = {
          'tag_name' => params[:tag_name],
          'name' => params[:name],
          'body' => params[:description],
          'draft' => !!params[:is_draft],
          'prerelease' => !!params[:is_prerelease]
        }
        body_obj['target_commitish'] = params[:commitish] if params[:commitish]
        body = body_obj.to_json

        repo_name = params[:repository_name]
        api_token = params[:api_token]

        # create the release
        response = call_releases_endpoint("post", repo_name, "/releases", api_token, body)

        case response[:status]
        when 201
          Helper.log.info "Successfully created release at tag \"#{params[:tag_name]}\" on GitHub".green
          body = JSON.parse(response.body)
          html_url = body['html_url']
          release_id = body['id']
          Helper.log.info "See release at \"#{html_url}\"".yellow
          Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_HTML_LINK] = html_url
          Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_RELEASE_ID] = release_id
          Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_JSON] = body

          assets = params[:upload_assets]
          if assets && assets.count > 0
            # upload assets
            self.upload_assets(assets, body['upload_url'], api_token)

            # fetch the release again, so that it contains the uploaded assets
            get_response = self.call_releases_endpoint("get", repo_name, "/releases/#{release_id}", api_token, nil)
            if get_response[:status] != 200
              Helper.log.error "GitHub responded with #{response[:status]}:#{response[:body]}".red
              raise "Failed to fetch the newly created release, but it *has been created* successfully.".red
            end

            get_body = JSON.parse(get_response.body)
            Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_JSON] = get_body
            Helper.log.info "Successfully uploaded assets #{assets} to release \"#{html_url}\"".green
            return get_body
          else
            return body
          end
        when 422
          Helper.log.error response.body
          Helper.log.error "Release on tag #{params[:tag_name]} already exists!".red
        when 404
          Helper.log.error response.body
          raise "Repository #{params[:repository_name]} cannot be found, please double check its name and that you provided a valid API token (if it's a private repository).".red
        when 401
          Helper.log.error response.body
          raise "You are not authorized to access #{params[:repository_name]}, please make sure you provided a valid API token.".red
        else
          if response[:status] != 200
            Helper.log.error "GitHub responded with #{response[:status]}:#{response[:body]}".red
          end
        end
        return nil
      end

      def self.upload_assets(assets, upload_url_template, api_token)
        assets.each do |asset|
          self.upload(asset, upload_url_template, api_token)
        end
      end

      def self.upload(asset_path, upload_url_template, api_token)
        # if it's a directory, zip it first in a temp directory, because we can only upload binary files
        absolute_path = File.absolute_path(asset_path)

        # check that the asset even exists
        raise "Asset #{absolute_path} doesn't exist" unless File.exist?(absolute_path)

        name = File.basename(absolute_path)
        response = nil
        if File.directory?(absolute_path)
          Dir.mktmpdir do |dir|
            tmpzip = File.join(dir, File.basename(absolute_path) + '.zip')
            name = File.basename(tmpzip)
            sh "cd \"#{File.dirname(absolute_path)}\"; zip -r \"#{tmpzip}\" \"#{File.basename(absolute_path)}\" 2>&1 >/dev/null"
            response = self.upload_file(tmpzip, upload_url_template, api_token)
          end
        else
          response = self.upload_file(absolute_path, upload_url_template, api_token)
        end
        return response
      end

      def self.upload_file(file, url_template, api_token)
        require 'addressable/template'
        name = File.basename(file)
        expanded_url = Addressable::Template.new(url_template).expand(name: name).to_s
        headers = self.headers(api_token)
        headers['Content-Type'] = 'application/zip' # how do we detect other types e.g. other binary files? file extensions?

        Helper.log.info "Uploading #{name}".yellow
        response = self.call_endpoint(expanded_url, "post", headers, File.read(file))

        # inspect the response
        case response.status
        when 201
          # all good in the hood
          Helper.log.info "Successfully uploaded #{name}.".green
        else
          Helper.log.error "GitHub responded with #{response[:status]}:#{response[:body]}".red
          raise "Failed to upload asset #{name} to GitHub."
        end
      end

      def self.call_endpoint(url, method, headers, body)
        require 'excon'
        case method
        when "post"
          response = Excon.post(url, headers: headers, body: body)
        when "get"
          response = Excon.get(url, headers: headers, body: body)
        else
          raise "Unsupported method #{method}"
        end
        return response
      end

      def self.call_releases_endpoint(method, repo, endpoint, api_token, body)
        url = "https://api.github.com/repos/#{repo}#{endpoint}"
        self.call_endpoint(url, method, self.headers(api_token), body)
      end

      def self.headers(api_token)
        require 'base64'
        headers = { 'User-Agent' => 'fastlane-set_github_release' }
        headers['Authorization'] = "Basic #{Base64.strict_encode64(api_token)}" if api_token
        headers
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This will create a new release on GitHub and upload assets for it"
      end

      def self.details
        "Creates a new release on GitHub. You must provide your GitHub Personal token
        (get one from https://github.com/settings/tokens/new), the repository name
        and tag name. By default that's 'master'. If the tag doesn't exist, one will be created on the commit or branch passed-in as
        commitish. Out parameters provide the release's id, which can be used for later editing and the
        release html link to GitHub. You can also specify a list of assets to be uploaded to the release with the upload_assets parameter."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repository_name,
                                       env_name: "FL_SET_GITHUB_RELEASE_REPOSITORY_NAME",
                                       description: "The path to your repo, e.g. 'KrauseFx/fastlane'",
                                       verify_block: proc do |value|
                                         raise "Please only pass the path, e.g. 'KrauseFx/fastlane'".red if value.include? "github.com"
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
                                       description: "Specifies the commitish value that determines where the Git tag is created from. Can be any branch or commit SHA. Unused if the Git tag already exists. Default: the repository's default branch (usually master)",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :description,
                                       env_name: "FL_SET_GITHUB_RELEASE_DESCRIPTION",
                                       description: "Description of this release",
                                       is_string: true,
                                       optional: true,
                                       default_value: Actions.lane_context[SharedValues::FL_CHANGELOG]),
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
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :upload_assets,
                                       env_name: "FL_SET_GITHUB_RELEASE_UPLOAD_ASSETS",
                                       description: "Path to assets to be uploaded with the release",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "upload_assets must be an Array of paths to assets" unless value.kind_of? Array
                                       end)
        ]
      end

      def self.output
        [
          ['SET_GITHUB_RELEASE_HTML_LINK', 'Link to your created release'],
          ['SET_GITHUB_RELEASE_RELEASE_ID', 'Release id (useful for subsequent editing)'],
          ['SET_GITHUB_RELEASE_JSON', 'The whole release JSON object']
        ]
      end

      def self.return_value
        [
          "A hash containing all relevant information of this release",
          "Access things like 'html_url', 'tag_name', 'name', 'body'"
        ].join("\n")
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
