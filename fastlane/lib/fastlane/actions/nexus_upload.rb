module Fastlane
  module Actions
    class NexusUploadAction < Action
      def self.run(params)
        command = []
        command << "curl"
        command << verbose(params)
        command += ssl_options(params)
        command += proxy_options(params)
        command += upload_options(params)
        command << upload_url(params)

        Fastlane::Actions.sh(command.join(' '), log: params[:verbose])
      end

      def self.upload_url(params)
        url = "#{params[:endpoint]}#{params[:mount_path]}"

        if params[:nexus_version] == 2
          url << "/service/local/artifact/maven/content"
        else
          file_extension = File.extname(params[:file]).shellescape

          url << "/repository/#{params[:repo_id]}"
          url << "/#{params[:repo_group_id].gsub('.', '/')}"
          url << "/#{params[:repo_project_name]}"
          url << "/#{params[:repo_project_version]}"
          url << "/#{params[:repo_project_name]}-#{params[:repo_project_version]}"
          url << "-#{params[:repo_classifier]}" if params[:repo_classifier]
          url << file_extension.to_s
        end

        url.shellescape
      end

      def self.verbose(params)
        params[:verbose] ? "--verbose" : "--silent"
      end

      def self.upload_options(params)
        file_path = File.expand_path(params[:file]).shellescape
        file_extension = file_path.split('.').last.shellescape

        options = []
        if params[:nexus_version] == 2
          options << "-F p=zip"
          options << "-F hasPom=false"
          options << "-F r=#{params[:repo_id].shellescape}"
          options << "-F g=#{params[:repo_group_id].shellescape}"
          options << "-F a=#{params[:repo_project_name].shellescape}"
          options << "-F v=#{params[:repo_project_version].shellescape}"

          if params[:repo_classifier]
            options << "-F c=#{params[:repo_classifier].shellescape}"
          end

          options << "-F e=#{file_extension}"
          options << "-F file=@#{file_path}"
        else
          options << "--upload-file #{file_path}"
        end

        options << "-u #{params[:username].shellescape}:#{params[:password].shellescape}"

        options
      end

      def self.ssl_options(params)
        options = []
        unless params[:ssl_verify]
          options << "--insecure"
        end

        options
      end

      def self.proxy_options(params)
        options = []
        if params[:proxy_address] && params[:proxy_port] && params[:proxy_username] && params[:proxy_password]
          options << "-x #{params[:proxy_address].shellescape}:#{params[:proxy_port].shellescape}"
          options << "--proxy-user #{params[:proxy_username].shellescape}:#{params[:proxy_password].shellescape}"
        end

        options
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload a file to [Sonatype Nexus platform](https://www.sonatype.com)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file,
                                       env_name: "FL_NEXUS_FILE",
                                       description: "File to be uploaded to Nexus",
                                       optional: false,
                                       verify_block: proc do |value|
                                         file_path = File.expand_path(value)
                                         UI.user_error!("Couldn't find file at path '#{file_path}'") unless File.exist?(file_path)
                                       end),
          FastlaneCore::ConfigItem.new(key: :repo_id,
                                       env_name: "FL_NEXUS_REPO_ID",
                                       description: "Nexus repository id e.g. artefacts",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repo_group_id,
                                       env_name: "FL_NEXUS_REPO_GROUP_ID",
                                       description: "Nexus repository group id e.g. com.company",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repo_project_name,
                                       env_name: "FL_NEXUS_REPO_PROJECT_NAME",
                                       description: "Nexus repository commandect name. Only letters, digits, underscores(_), hyphens(-), and dots(.) are allowed",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repo_project_version,
                                       env_name: "FL_NEXUS_REPO_PROJECT_VERSION",
                                       description: "Nexus repository commandect version",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repo_classifier,
                                       env_name: "FL_NEXUS_REPO_CLASSIFIER",
                                       description: "Nexus repository artifact classifier (optional)",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :endpoint,
                                       env_name: "FL_NEXUS_ENDPOINT",
                                       description: "Nexus endpoint e.g. http://nexus:8081",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :mount_path,
                                       env_name: "FL_NEXUS_MOUNT_PATH",
                                       description: "Nexus mount path (Nexus 3 instances have this configured as empty by default)",
                                       default_value: "/nexus",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_NEXUS_USERNAME",
                                       description: "Nexus username",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_NEXUS_PASSWORD",
                                       description: "Nexus password",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :ssl_verify,
                                       env_name: "FL_NEXUS_SSL_VERIFY",
                                       description: "Verify SSL",
                                       is_string: false,
                                       default_value: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :nexus_version,
                                       env_name: "FL_NEXUS_MAJOR_VERSION",
                                       description: "Nexus major version",
                                       type: Integer,
                                       default_value: 2,
                                       optional: true,
                                       verify_block: proc do |value|
                                         min_version = 2
                                         max_version = 3
                                         UI.user_error!("Unsupported version (#{value}) min. supported version: #{min_version}") unless value >= min_version
                                         UI.user_error!("Unsupported version (#{value}) max. supported version: #{max_version}") unless value <= max_version
                                       end),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_NEXUS_VERBOSE",
                                       description: "Make detailed output",
                                       is_string: false,
                                       default_value: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_username,
                                       env_name: "FL_NEXUS_PROXY_USERNAME",
                                       description: "Proxy username",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_password,
                                       env_name: "FL_NEXUS_PROXY_PASSWORD",
                                       sensitive: true,
                                       description: "Proxy password",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_address,
                                       env_name: "FL_NEXUS_PROXY_ADDRESS",
                                       description: "Proxy address",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_port,
                                       env_name: "FL_NEXUS_PROXY_PORT",
                                       description: "Proxy port",
                                       optional: true)
        ]
      end

      def self.authors
        ["xfreebird", "mdio"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          '# for Nexus 2
          nexus_upload(
            file: "/path/to/file.ipa",
            repo_id: "artefacts",
            repo_group_id: "com.fastlane",
            repo_project_name: "ipa",
            repo_project_version: "1.13",
            repo_classifier: "dSYM", # Optional
            endpoint: "http://localhost:8081",
            username: "admin",
            password: "admin123"
          )',
          '# for Nexus 3
          nexus_upload(
            nexus_version: 3,
            mount_path: "",
            file: "/path/to/file.ipa",
            repo_id: "artefacts",
            repo_group_id: "com.fastlane",
            repo_project_name: "ipa",
            repo_project_version: "1.13",
            repo_classifier: "dSYM", # Optional
            endpoint: "http://localhost:8081",
            username: "admin",
            password: "admin123"
          )'
        ]
      end

      def self.category
        :beta
      end
    end
  end
end
