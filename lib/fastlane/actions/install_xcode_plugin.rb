module Fastlane
  module Actions
    class InstallXcodePluginAction < Action
      def self.run(params)
        require 'fileutils'

        zip_path = File.join(Dir.tmpdir, 'plugin.zip')
        sh "curl -Lso #{zip_path} #{params[:url]}"
        plugins_path = "#{ENV['HOME']}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
        FileUtils.mkdir_p(plugins_path)
        Action.sh "unzip -qo '#{zip_path}' -d '#{plugins_path}'"

        Helper.log.info("Plugin #{File.basename(params[:url], '.zip')} installed successfully".green)
        Helper.log.info("Please restart Xcode to use the newly installed plugin")
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
                                         raise "No URL for InstallXcodePluginAction given, pass using `url: 'url'`".red if value.to_s.length == 0
                                         raise "URL doesn't use HTTPS".red unless value.start_with?("https://")
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
    end
  end
end
