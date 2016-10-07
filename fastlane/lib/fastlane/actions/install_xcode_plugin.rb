module Fastlane
  module Actions
    class InstallXcodePluginAction < Action
      def self.run(params)
        require 'fileutils'

        unless params[:github].nil?
          github_api_url = params[:github].sub('https://github.com', 'https://api.github.com/repos')
          release = self.fetch_json(github_api_url + '/releases/latest')
          return if release.nil?
          params[:url] = release['assets'][0]['browser_download_url']
        end

        zip_path = File.join(Dir.tmpdir, 'plugin.zip')
        sh "curl -Lso #{zip_path} #{params[:url]}"
        plugins_path = "#{ENV['HOME']}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
        FileUtils.mkdir_p(plugins_path)
        Action.sh "unzip -qo '#{zip_path}' -d '#{plugins_path}'"

        UI.success("Plugin #{File.basename(params[:url], '.zip')} installed successfully")
        UI.message("Please restart Xcode to use the newly installed plugin")
      end

      def self.fetch_json(url)
        require 'excon'
        require 'json'

        response = Excon.get(url)

        if response[:status] != 200
          if response[:status] == 404
            UI.error("No latest release found for the specified GitHub repository")
          else
            UI.error("GitHub responded with #{response[:status]}:#{response[:body]}")
          end
          return nil
        end

        JSON.parse(response.body)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Install an Xcode plugin for the current user"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "FL_XCODE_PLUGIN_URL",
                                       description: "URL for Xcode plugin ZIP file",
                                       verify_block: proc do |value|
                                         UI.user_error!("No URL for InstallXcodePluginAction given, pass using `url: 'url'`") if value.to_s.length == 0
                                         UI.user_error!("URL doesn't use HTTPS") unless value.start_with?("https://")
                                       end),
          FastlaneCore::ConfigItem.new(key: :github,
                                       env_name: "FL_XCODE_PLUGIN_GITHUB",
                                       description: "GitHub repository URL for Xcode plugin",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No GitHub URL for InstallXcodePluginAction given, pass using `github: 'url'`") if value.to_s.length == 0
                                         UI.user_error!("URL doesn't use HTTPS") unless value.start_with?("https://")
                                       end)
        ]
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["NeoNachoSoto"]
      end

      def self.is_supported?(platform)
        [:ios, :mac, :tvos, :watchos, :caros].include?(platform)
      end

      def self.example_code
        [
          'install_xcode_plugin(url: "https://example.com/clubmate/plugin.zip")',
          'install_xcode_plugin(github: "https://github.com/contentful/ContentfulXcodePlugin")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
