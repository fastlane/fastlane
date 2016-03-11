module Fastlane
  module Actions
    class UploadSymbolsToCrashlyticsAction < Action
      def self.run(params)
        params[:binary_path] ||= (Dir["/Applications/Fabric.app/**/upload-symbols"] + Dir["./Pods/**/upload-symbols"]).last
        UI.user_error!("Please provide a path to the binary using binary_path:") unless params[:binary_path]

        unless params[:api_token].to_s.length > 0
          Dir["./**/Info.plist"].each do |current|
            result = Actions::GetInfoPlistValueAction.run(path: current, key: "Fabric")
            next unless result
            params[:api_token] ||= result["APIKey"]
          end
        end
        UI.user_error!("Please provide an api_token using api_token:") unless params[:api_token]

        command = []
        command << File.expand_path(params[:binary_path])
        command << "-a #{params[:api_token]}"
        command << "-p #{params[:platform]}"
        command << File.expand_path(params[:dsym_path])

        return Actions.sh command.join(" ")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload dSYM symbolication files to Crashlytics"
      end

      def self.details
        [
          "This action allows you to upload symbolication files to Crashlytics.",
          "It's extra useful if you use it to download the latest dSYM files from Apple when you",
          "use Bitcode"
        ].join(" ")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dsym_path,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_CRASHLYTICS_DSYM_PATH",
                                       description: "Path to the DSYM file or zip to upload",
                                       default_value: ENV[SharedValues::DSYM_OUTPUT_PATH.to_s] || (Dir["./**/*.dSYM"] + Dir["./**/*.dSYM.zip"]).first,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                         UI.user_error!("Symbolication file needs to be dSYM or zip") unless value.end_with?("dSYM.zip", ".dSYM")
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "CRASHLYTICS_API_TOKEN",
                                       optional: true,
                                       description: "Crashlytics Beta API Token",
                                       verify_block: proc do |value|
                                         UI.user_error!("No API token for Crashlytics given, pass using `api_token: 'token'`") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :binary_path,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_CRASHLYTICS_BINARY_PATH",
                                       description: "The path to the upload-symbols file",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_CRASHLYTICS_PLATFORM",
                                       description: "The platform of the app (ios, tvos, mac)",
                                       default_value: "ios",
                                       verify_block: proc do |value|
                                         available = ['ios', 'tvos', 'mac']
                                         UI.user_error!("Invalid platform '#{value}', must be #{available.join(', ')}") unless available.include?(value)
                                       end)
        ]
      end

      def self.output
        nil
      end

      def self.return_value
        nil
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
