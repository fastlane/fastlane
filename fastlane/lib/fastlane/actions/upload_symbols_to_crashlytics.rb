module Fastlane
  module Actions
    class UploadSymbolsToCrashlyticsAction < Action
      def self.run(params)
        require 'tmpdir'

        find_binary_path(params)
        find_api_token(params)

        dsym_paths = []
        dsym_paths << params[:dsym_path] if params[:dsym_path]
        dsym_paths += Actions.lane_context[SharedValues::DSYM_PATHS] if Actions.lane_context[SharedValues::DSYM_PATHS]

        if dsym_paths.count == 0
          UI.error("Couldn't find any dSYMs, please pass them using the dsym_path option")
          return nil
        end

        # Get rid of duplicates (which might occur when both passed and detected)
        dsym_paths = dsym_paths.collect { |a| File.expand_path(a) }
        dsym_paths.uniq!

        dsym_paths.each do |current_path|
          handle_dsym(params, current_path)
        end

        UI.success("Successfully uploaded dSYM files to Crashlytics 💯")
      end

      # @param current_path this is a path to either a dSYM or a zipped dSYM
      #   this might also be either nested or not, we're flexible
      def self.handle_dsym(params, current_path)
        if current_path.end_with?(".dSYM")
          upload_dsym(params, current_path)
        elsif current_path.end_with?(".zip")
          UI.message("Extracting '#{current_path}'...")

          current_path = File.expand_path(current_path)
          Dir.mktmpdir do |dir|
            Dir.chdir(dir) do
              Actions.sh("unzip -qo #{current_path.shellescape}")
              Dir["*.dSYM"].each do |sub|
                handle_dsym(params, sub)
              end
            end
          end
        else
          UI.error "Don't know how to handle '#{current_path}'"
        end
      end

      def self.upload_dsym(params, path)
        UI.message("Uploading '#{path}'...")
        command = []
        command << params[:binary_path].shellescape
        command << "-a #{params[:api_token]}"
        command << "-p #{params[:platform]}"
        command << File.expand_path(path).shellescape
        begin
          Actions.sh(command.join(" "), log: false)
        rescue => ex
          UI.error ex.to_s # it fails, however we don't want to fail everything just for this
        end
      end

      def self.find_api_token(params)
        unless params[:api_token].to_s.length > 0
          Dir["./**/Info.plist"].each do |current|
            result = Actions::GetInfoPlistValueAction.run(path: current, key: "Fabric")
            next unless result
            next unless result.kind_of?(Hash)
            params[:api_token] ||= result["APIKey"]
          end
        end
        UI.user_error!("Please provide an api_token using api_token:") unless params[:api_token]
      end

      def self.find_binary_path(params)
        params[:binary_path] ||= (Dir["/Applications/Fabric.app/**/upload-symbols"] + Dir["./Pods/**/upload-symbols"]).last
        UI.user_error!("Please provide a path to the binary using binary_path:") unless params[:binary_path]

        params[:binary_path] = File.expand_path(params[:binary_path])
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
          "use Bitcode. This action will not fail the build if one of the uploads failed.",
          "The reason for that is that sometimes some of dSYM files are invalid, and we don't want",
          "them to fail the complete build."
        ].join(" ")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dsym_path,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_CRASHLYTICS_DSYM_PATH",
                                       description: "Path to the DSYM file or zip to upload",
                                       default_value: ENV[SharedValues::DSYM_OUTPUT_PATH.to_s] || (Dir["./**/*.dSYM"] + Dir["./**/*.dSYM.zip"]).first,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                         UI.user_error!("Symbolication file needs to be dSYM or zip") unless value.end_with?(".zip", ".dSYM")
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "CRASHLYTICS_API_TOKEN",
                                       sensitive: true,
                                       optional: true,
                                       description: "Crashlytics API Key",
                                       verify_block: proc do |value|
                                         UI.user_error!("No API token for Crashlytics given, pass using `api_token: 'token'`") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :binary_path,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_CRASHLYTICS_BINARY_PATH",
                                       description: "The path to the upload-symbols file of the Fabric app",
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

      def self.example_code
        [
          'upload_symbols_to_crashlytics(dsym_path: "./App.dSYM.zip")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
