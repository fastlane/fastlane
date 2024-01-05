module Fastlane
  module Actions
    class InstallXcodePluginAction < Action
      def self.run(params)
        require 'fileutils'

        if params[:github]
          base_api_url = params[:github].sub('https://github.com', 'https://api.github.com/repos')

          GithubApiAction.run(
            url: File.join(base_api_url, 'releases/latest'),
            http_method: 'GET',
            error_handlers: {
              404 => proc do |result|
                UI.error("No latest release found for the specified GitHub repository")
              end,
              '*' => proc do |result|
                UI.error("GitHub responded with #{response[:status]}:#{response[:body]}")
              end
            }
          ) do |result|
            return nil if result[:json].nil?
            params[:url] = result[:json]['assets'][0]['browser_download_url']
          end
        end

        zip_path = File.join(Dir.tmpdir, 'plugin.zip')
        sh("curl -Lso #{zip_path} #{params[:url]}")
        plugins_path = "#{ENV['HOME']}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
        FileUtils.mkdir_p(plugins_path)
        Action.sh("unzip -qo '#{zip_path}' -d '#{plugins_path}'")

        UI.success("Plugin #{File.basename(params[:url], '.zip')} installed successfully")
        UI.message("Please restart Xcode to use the newly installed plugin")
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
        ["NeoNachoSoto", "tommeier"]
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
