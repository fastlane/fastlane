module Fastlane
  module Actions
    module SharedValues
      ARTIFACTORY_DOWNLOAD_URL = :ARTIFACTORY_DOWNLOAD_URL
      ARTIFACTORY_DOWNLOAD_SIZE = :ARTIFACTORY_DOWNLOAD_SIZE
    end

    class ArtifactoryAction < Action
      def self.run(params)
        Actions.verify_gem!('artifactory')

        require 'artifactory'
        file_path = File.absolute_path(params[:file])
        if File.exist?(file_path)
          client = connect_to_artifactory(params)
          artifact = Artifactory::Resource::Artifact.new
          artifact.client = client
          artifact.local_path = file_path
          artifact.checksums = {
              "sha1" => Digest::SHA1.file(file_path),
              "md5" => Digest::MD5.file(file_path)
          }
          UI.message("Uploading file: #{artifact.local_path} ...")
          upload = artifact.upload(params[:repo], params[:repo_path], params[:properties])

          Actions.lane_context[SharedValues::ARTIFACTORY_DOWNLOAD_URL] = upload.uri
          Actions.lane_context[SharedValues::ARTIFACTORY_DOWNLOAD_SIZE] = upload.size

          UI.message("Uploaded Artifact:")
          UI.message("Repo: #{upload.repo}")
          UI.message("URI: #{upload.uri}")
          UI.message("Size: #{upload.size}")
          UI.message("SHA1: #{upload.sha1}")
        else
          UI.message("File not found: '#{file_path}'")
        end
      end

      def self.connect_to_artifactory(params)
        config_keys = [:endpoint, :username, :password, :ssl_pem_file, :ssl_verify, :proxy_username, :proxy_password, :proxy_address, :proxy_port]
        config = params.values.select do |key|
          config_keys.include?(key)
        end
        Artifactory::Client.new(config)
      end

      def self.description
        'This action uploads an artifact to artifactory'
      end

      def self.is_supported?(platform)
        true
      end

      def self.author
        ["koglinjg", "tommeier"]
      end

      def self.output
        [
          ['ARTIFACTORY_DOWNLOAD_URL', 'The download url for file uploaded'],
          ['ARTIFACTORY_DOWNLOAD_SIZE', 'The reported file size for file uploaded']
        ]
      end

      def self.example_code
        [
          'artifactory(
            username: "username",
            password: "password",
            endpoint: "https://artifactory.example.com/artifactory/",
            file: "example.ipa",                                # File to upload
            repo: "mobile_artifacts",                           # Artifactory repo
            repo_path: "/ios/appname/example-major.minor.ipa"   # Path to place the artifact including its filename
          )'
        ]
      end

      def self.category
        :misc
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file,
                                       env_name: "FL_ARTIFACTORY_FILE",
                                       description: "File to be uploaded to artifactory",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repo,
                                       env_name: "FL_ARTIFACTORY_REPO",
                                       description: "Artifactory repo to put the file in",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repo_path,
                                       env_name: "FL_ARTIFACTORY_REPO_PATH",
                                       description: "Path to deploy within the repo, including filename",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :endpoint,
                                       env_name: "FL_ARTIFACTORY_ENDPOINT",
                                       description: "Artifactory endpoint",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_ARTIFACTORY_USERNAME",
                                       description: "Artifactory username",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_ARTIFACTORY_PASSWORD",
                                       description: "Artifactory password",
                                       sensitive: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :properties,
                                       env_name: "FL_ARTIFACTORY_PROPERTIES",
                                       description: "Artifact properties hash",
                                       is_string: false,
                                       default_value: {},
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ssl_pem_file,
                                       env_name: "FL_ARTIFACTORY_SSL_PEM_FILE",
                                       description: "Location of pem file to use for ssl verification",
                                       default_value: nil,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ssl_verify,
                                       env_name: "FL_ARTIFACTORY_SSL_VERIFY",
                                       description: "Verify SSL",
                                       is_string: false,
                                       default_value: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_username,
                                       env_name: "FL_ARTIFACTORY_PROXY_USERNAME",
                                       description: "Proxy username",
                                       default_value: nil,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_password,
                                       env_name: "FL_ARTIFACTORY_PROXY_PASSWORD",
                                       description: "Proxy password",
                                       sensitive: true,
                                       default_value: nil,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_address,
                                       env_name: "FL_ARTIFACTORY_PROXY_ADDRESS",
                                       description: "Proxy address",
                                       default_value: nil,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_port,
                                       env_name: "FL_ARTIFACTORY_PROXY_PORT",
                                       description: "Proxy port",
                                       default_value: nil,
                                       optional: true)
        ]
      end
    end
  end
end
