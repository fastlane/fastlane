module Fastlane
  module Actions
    module SharedValues
      SET_GITHUB_RELEASE_HTML_LINK = :SET_GITHUB_RELEASE_HTML_LINK
      SET_GITHUB_RELEASE_RELEASE_ID = :SET_GITHUB_RELEASE_RELEASE_ID
      SET_GITHUB_RELEASE_JSON = :SET_GITHUB_RELEASE_JSON
    end

    class SetGithubReleaseAction < Action
      def self.run(params)
        UI.important("Creating release of #{params[:repository_name]} on tag \"#{params[:tag_name]}\" with name \"#{params[:name]}\".")
        UI.important("Will also upload assets #{params[:upload_assets]}.") if params[:upload_assets]

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
        server_url = params[:server_url]
        server_url = server_url[0..-2] if server_url.end_with? '/'

        # create the release
        response = call_releases_endpoint("post", server_url, repo_name, "/releases", api_token, body)

        case response[:status]
        when 201
          UI.success("Successfully created release at tag \"#{params[:tag_name]}\" on GitHub")
          body = JSON.parse(response.body)
          html_url = body['html_url']
          release_id = body['id']
          UI.important("See release at \"#{html_url}\"")
          Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_HTML_LINK] = html_url
          Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_RELEASE_ID] = release_id
          Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_JSON] = body

          assets = params[:upload_assets]
          if assets && assets.count > 0
            # upload assets
            self.upload_assets(assets, body['upload_url'], api_token)

            # fetch the release again, so that it contains the uploaded assets
            get_response = self.call_releases_endpoint("get", server_url, repo_name, "/releases/#{release_id}", api_token, nil)
            if get_response[:status] != 200
              UI.error("GitHub responded with #{response[:status]}:#{response[:body]}")
              UI.user_error!("Failed to fetch the newly created release, but it *has been created* successfully.")
            end

            get_body = JSON.parse(get_response.body)
            Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_JSON] = get_body
            UI.success("Successfully uploaded assets #{assets} to release \"#{html_url}\"")
            return get_body
          else
            return body
          end
        when 422
          UI.error(response.body)
          UI.error("Release on tag #{params[:tag_name]} already exists!")
        when 404
          UI.error(response.body)
          UI.user_error!("Repository #{params[:repository_name]} cannot be found, please double check its name and that you provided a valid API token (GITHUB_API_TOKEN)")
        when 401
          UI.error(response.body)
          UI.user_error!("You are not authorized to access #{params[:repository_name]}, please make sure you provided a valid API token (GITHUB_API_TOKEN)")
        else
          if response[:status] != 200
            UI.error("GitHub responded with #{response[:status]}:#{response[:body]}")
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
        UI.user_error!("Asset #{absolute_path} doesn't exist") unless File.exist?(absolute_path)

        name = File.basename(absolute_path)
        response = nil
        if File.directory?(absolute_path)
          Dir.mktmpdir do |dir|
            tmpzip = File.join(dir, File.basename(absolute_path) + '.zip')
            name = File.basename(tmpzip)
            sh "cd \"#{File.dirname(absolute_path)}\"; zip -r --symlinks \"#{tmpzip}\" \"#{File.basename(absolute_path)}\" 2>&1 >/dev/null"
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

        UI.important("Uploading #{name}")
        response = self.call_endpoint(expanded_url, "post", headers, File.read(file))

        # inspect the response
        case response.status
        when 201
          # all good in the hood
          UI.success("Successfully uploaded #{name}.")
        else
          UI.error("GitHub responded with #{response[:status]}:#{response[:body]}")
          UI.user_error!("Failed to upload asset #{name} to GitHub.")
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
          UI.user_error!("Unsupported method #{method}")
        end
        return response
      end

      def self.call_releases_endpoint(method, server, repo, endpoint, api_token, body)
        url = "#{server}/repos/#{repo}#{endpoint}"
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
                                       description: "The path to your repo, e.g. 'fastlane/fastlane'",
                                       verify_block: proc do |value|
                                         UI.user_error!("Please only pass the path, e.g. 'fastlane/fastlane'") if value.include? "github.com"
                                         UI.user_error!("Please only pass the path, e.g. 'fastlane/fastlane'") if value.split('/').count != 2
                                       end),
          FastlaneCore::ConfigItem.new(key: :server_url,
                                       env_name: "FL_GITHUB_RELEASE_SERVER_URL",
                                       description: "The server url. e.g. 'https://your.internal.github.host/api/v3' (Default: 'https://api.github.com')",
                                       default_value: "https://api.github.com",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please include the protocol in the server url, e.g. https://your.github.server/api/v3") unless value.include? "//"
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_GITHUB_RELEASE_API_TOKEN",
                                       description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                       is_string: true,
                                       default_value: ENV["GITHUB_API_TOKEN"],
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
                                         UI.user_error!("upload_assets must be an Array of paths to assets") unless value.kind_of? Array
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

      def self.example_code
        [
          'github_release = set_github_release(
            repository_name: "fastlane/fastlane",
            api_token: ENV["GITHUB_TOKEN"],
            name: "Super New actions",
            tag_name: "v1.22.0",
            description: (File.read("changelog") rescue "No changelog provided"),
            commitish: "master",
            upload_assets: ["example_integration.ipa", "./pkg/built.gem"]
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
