module Fastlane
  module Actions
    class UploadSymbolsToNewRelicAction < Action
      def self.run(params)
        dsym_paths = get_all_dsym_paths(params)

        if dsym_paths.count == 0
          UI.error("Couldn't find any dSYMs, please pass them using the dsym_path option")
          return nil
        end

        dsym_paths.each do |current_path|
          handle_dsym(params, current_path)
        end
      end

      def self.get_all_dsym_paths(params)
        dsym_paths = []
        dsym_paths << params[:dsym_path] if params[:dsym_path]
        dsym_paths += Actions.lane_context[SharedValues::DSYM_PATHS] if Actions.lane_context[SharedValues::DSYM_PATHS]

        # Get rid of duplicates (which might occur when both passed and detected)
        dsym_paths = dsym_paths.collect { |a| File.expand_path(a) }
        dsym_paths.uniq!

        return dsym_paths
      end

      # @param current_path this is a path to either a dSYM or a zipped dSYM
      #   this might also be either nested or not, we're flexible
      def self.handle_dsym(params, current_path)
        if current_path.end_with?(".dSYM")
          dwarf_dump = Actions.sh("xcrun dwarfdump --uuid #{current_path}")
          upload_dsym(params, current_path, dwarf_dump)
        elsif current_path.end_with?(".zip")
          UI.message("Extracting '#{current_path}'...")

          current_path = File.expand_path(current_path)
          Dir.mktmpdir do |dir|
            Dir.chdir(dir) do
              Actions.sh("unzip -qo #{current_path.shellescape}")
              Dir["*.dSYM"].each do |path|
                handle_dsym(params, path)
              end
            end
          end
        else
          UI.error "Don't know how to handle '#{current_path}'"
        end
      end

      def self.upload_dsym(params, path, dwarf_dump)
        if dwarf_dump.nil?
          return
        end

        app_name = params[:new_relic_app_name]
        uploadable_lib_names = (params[:new_relic_upload_libs] || "").split(",")
        new_relic_key = params[:new_relic_license_key]

        all_included_architecture_info = dwarf_dump.split("\n").map { |line| transform_architecture_symbol_info(line) }
        lib_name = all_included_architecture_info[0][:lib_name]

        # if we haven't specified any upload libs, we'll upload them all
        # otherwise, check that the lib+name from the dwarfdump is in our list
        if uploadable_lib_names.count == 0 || uploadable_lib_names.include?(lib_name)
          build_ids = all_included_architecture_info.map { |info| info[:uuid] } .join(",")
          zip_file_name = "#{path}.zip"
          sh "zip --recurse-paths --quiet '#{zip_file_name}' '#{path}'"
          sh "curl -F dsym=@'#{zip_file_name}' -F buildId='#{build_ids}' -F appName='#{app_name}' -H 'X-APP-LICENSE-KEY: #{new_relic_key}' https://mobile-symbol-upload.newrelic.com/symbol"
        end
      end

      def self.transform_architecture_symbol_info(architecture_symbol_info)
        # dwarfdump returns lines in the format "UUID: THE-dSYM-UUID-HERE (architecture) path/to/lib"
        dsym_info_components = architecture_symbol_info.split(" ")
        uuid = dsym_info_components[1]
        uuid.delete! '-'
        uuid = uuid.downcase

        lib_path = dsym_info_components.last
        lib_name = lib_path.split("/").last

        return { uuid: uuid, lib_name: lib_name }
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload all dsyms (possibly in a zip file) to new relic"
      end

      def self.details
        "Upload all dsyms (possibly in a zip file) to new relic"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :new_relic_app_name,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_NEW_RELIC_APP_NAME",
                                       description: "The name of your app",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("No app name for New Relic given, pass using `new_relic_app_name: 'app name'`") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :new_relic_license_key,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_NEW_RELIC_LICENSE_KEY",
                                       description: "Your New Relic app license key",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("No license key for New Relic given, pass using `new_relic_license_key: 'key'`") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :dsym_path,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_NEW_RELIC_DSYM_PATH",
                                       description: "Path to the DSYM file or zip to upload",
                                       default_value: ENV[SharedValues::DSYM_OUTPUT_PATH.to_s] || (Dir["./**/*.dSYM"] + Dir["./**/*.dSYM.zip"]).first,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                         UI.user_error!("Symbolication file needs to be dSYM or zip") unless value.end_with?(".zip", ".dSYM")
                                       end),
          FastlaneCore::ConfigItem.new(key: :new_relic_upload_libs,
                                       env_name: "FL_UPLOAD_SYMBOLS_TO_NEW_RELIC_UPLOAD_LIBS",
                                       description: "The library names to upload",
                                       optional: true)
        ]
      end

      def self.output
        []
      end

      def self.return_value
        nil
      end

      def self.authors
        ["bitwit"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
