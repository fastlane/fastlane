require 'thread'

module Fastlane
  module Actions
    class UploadSymbolsToCrashlyticsAction < Action
      def self.run(params)
        require 'tmpdir'

        find_binary_path(params)
        find_gsp_path(params)
        find_api_token(params)

        if !params[:api_token] && !params[:gsp_path]
          UI.user_error!('Either Fabric API key or path to Firebase Crashlytics GoogleService-Info.plist must be given.')
        end

        dsym_paths = []
        dsym_paths << params[:dsym_path] if params[:dsym_path]
        dsym_paths += Actions.lane_context[SharedValues::DSYM_PATHS] if Actions.lane_context[SharedValues::DSYM_PATHS]

        # Allows adding of additional multiple dsym_paths since :dsym_path can be autoset by other actions
        dsym_paths += params[:dsym_paths] if params[:dsym_paths]

        if dsym_paths.count == 0
          UI.error("Couldn't find any dSYMs, please pass them using the dsym_path option")
          return nil
        end

        # Get rid of duplicates (which might occur when both passed and detected)
        dsym_paths = dsym_paths.collect { |a| File.expand_path(a) }
        dsym_paths.uniq!

        max_worker_threads = params[:dsym_worker_threads]
        if max_worker_threads > 1
          UI.message("Using #{max_worker_threads} threads for Crashlytics dSYM upload 🏎")
        end

        dsym_paths.each do |current_path|
          handle_dsym(params, current_path, max_worker_threads)
        end

        UI.success("Successfully uploaded dSYM files to Crashlytics 💯")
      end

      # @param current_path this is a path to either a dSYM or a zipped dSYM
      #   this might also be either nested or not, we're flexible
      def self.handle_dsym(params, current_path, max_worker_threads)
        if current_path.end_with?(".dSYM")
          upload_dsym(params, current_path)
        elsif current_path.end_with?(".zip")
          UI.message("Extracting '#{current_path}'...")

          current_path = File.expand_path(current_path)
          Dir.mktmpdir do |dir|
            Dir.chdir(dir) do
              Actions.sh("unzip -qo #{current_path.shellescape}")
              work_q = Queue.new
              Dir["*.dSYM"].each do |sub|
                work_q.push(sub)
              end
              execute_uploads(params, max_worker_threads, work_q)
            end
          end
        else
          UI.error("Don't know how to handle '#{current_path}'")
        end
      end

      def self.execute_uploads(params, max_worker_threads, work_q)
        number_of_threads = [max_worker_threads, work_q.size].min
        workers = (0...number_of_threads).map do
          Thread.new do
            begin
              while work_q.size > 0
                current_path = work_q.pop(true)
                upload_dsym(params, current_path)
              end
            rescue => ex
              UI.error(ex.to_s)
            end
          end
        end
        workers.map(&:join)
      end

      def self.upload_dsym(params, path)
        UI.message("Uploading '#{path}'...")
        command = []
        command << File.expand_path(params[:binary_path]).shellescape
        if params[:gsp_path]
          command << "-gsp #{params[:gsp_path].shellescape}"
        elsif params[:api_token]
          command << "-a #{params[:api_token]}"
        end
        command << "-p #{params[:platform] == 'appletvos' ? 'tvos' : params[:platform]}"
        command << File.expand_path(path).shellescape
        begin
          command_to_execute = command.join(" ")
          UI.verbose("upload_dsym using command: #{command_to_execute}")
          Actions.sh(command_to_execute, log: false)
        rescue => ex
          UI.error(ex.to_s) # it fails, however we don't want to fail everything just for this
        end
      end

      def self.find_api_token(params)
        return if params[:gsp_path]
        unless params[:api_token].to_s.length > 0
          Dir["./**/Info.plist"].each do |current|
            result = Actions::GetInfoPlistValueAction.run(path: current, key: "Fabric")
            next unless result
            next unless result.kind_of?(Hash)
            params[:api_token] ||= result["APIKey"]
            UI.verbose("found an APIKey in #{current}")
          end
        end
      end

      def self.find_gsp_path(params)
        return if params[:api_token]

        if params[:gsp_path].to_s.length > 0
          params[:gsp_path] = File.expand_path(params[:gsp_path])
        else
          gsp_path = Dir["./**/GoogleService-Info.plist"].first
          params[:gsp_path] = File.expand_path(gsp_path) unless gsp_path.nil?
        end
      end

      def self.find_binary_path(params)
        params[:binary_path] ||= (Dir["/Applications/Fabric.app/**/upload-symbols"] + Dir["./Pods/**/upload-symbols"]).last
        UI.user_error!("Failed to find Fabric's upload_symbols binary at /Applications/Fabric.app/**/upload-symbols or ./Pods/**/upload-symbols. Please specify the location of the binary explicitly by using the binary_path option") unless params[:binary_path]

        params[:binary_path] = File.expand_path(params[:binary_path])
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload dSYM symbolication files to Crashlytics"
      end

      def self.details
        "This action allows you to upload symbolication files to Crashlytics. It's extra useful if you use it to download the latest dSYM files from Apple when you use Bitcode. This action will not fail the build if one of the uploads failed. The reason for that is that sometimes some of dSYM files are invalid, and we don't want them to fail the complete build."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dsym_path,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_CRASHLYTICS_DSYM_PATH",
                                       description: "Path to the DSYM file or zip to upload",
                                       default_value: ENV[SharedValues::DSYM_OUTPUT_PATH.to_s] || (Dir["./**/*.dSYM"] + Dir["./**/*.dSYM.zip"]).sort_by { |f| File.mtime(f) }.last,
                                       default_value_dynamic: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                         UI.user_error!("Symbolication file needs to be dSYM or zip") unless value.end_with?(".zip", ".dSYM")
                                       end),
          FastlaneCore::ConfigItem.new(key: :dsym_paths,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_CRASHLYTICS_DSYM_PATHS",
                                       description: "Paths to the DSYM files or zips to upload",
                                       optional: true,
                                       type: Array,
                                       verify_block: proc do |values|
                                         values.each do |value|
                                           UI.user_error!("Couldn't find file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                           UI.user_error!("Symbolication file needs to be dSYM or zip") unless value.end_with?(".zip", ".dSYM")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "CRASHLYTICS_API_TOKEN",
                                       sensitive: true,
                                       optional: true,
                                       description: "Crashlytics API Key",
                                       verify_block: proc do |value|
                                         UI.user_error!("No API token for Crashlytics given, pass using `api_token: 'token'`") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :gsp_path,
                                       env_name: "GOOGLE_SERVICES_INFO_PLIST_PATH",
                                       code_gen_sensitive: true,
                                       optional: true,
                                       description: "Path to GoogleService-Info.plist",
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                         UI.user_error!("No Path to GoogleService-Info.plist for Firebase Crashlytics given, pass using `gsp_path: 'path'`") if value.to_s.length == 0
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
                                       description: "The platform of the app (ios, appletvos, mac)",
                                       default_value: "ios",
                                       verify_block: proc do |value|
                                         available = ['ios', 'appletvos', 'mac']
                                         UI.user_error!("Invalid platform '#{value}', must be #{available.join(', ')}") unless available.include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :dsym_worker_threads,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_CRASHLYTICS_DSYM_WORKER_THREADS",
                                       type: Integer,
                                       default_value: 1,
                                       optional: true,
                                       description: "The number of threads to use for simultaneous dSYM upload",
                                       verify_block: proc do |value|
                                         min_threads = 1
                                         UI.user_error!("Too few threads (#{value}) minimum number of threads: #{min_threads}") unless value >= min_threads
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
        [:ios, :appletvos].include?(platform)
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
