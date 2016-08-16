module Fastlane
  module Actions
    class TpaAction < Action
      def self.run(params)
        command = []
        command << "curl"
        command << verbose(params)
        command += upload_options(params)
        command << upload_url(params)

        shell_command = command.join(' ')
        return shell_command if Helper.is_test?
        result = Actions.sh(shell_command, log: params[:verbose])
        fail_on_error(result)
      end

      def self.fail_on_error(result)
        if result == "OK"
          UI.success('Your app has been uploaded to TPA')
        else
          UI.user_error!("Something went wrong while uploading your app to TPA: #{result}")
        end
      end

      def self.upload_options(params)
        app_file = app_file(params)

        options = []
        options << "-F app=@#{app_file}"

        if params[:mapping]
          options << "-F mapping=@#{params[:mapping]}"
        end

        options << "-F publish=#{params[:publish]}"

        if params[:notes]
          options << "-F notes=#{params[:notes]}"
        end

        options << "-F force=#{params[:force]}"

        options
      end

      def self.app_file(params)
        app_file = [
          params[:ipa],
          params[:apk]
        ].detect { |e| !e.to_s.empty? }

        if app_file.nil?
          UI.user_error!("You have to provide a build file")
        end

        app_file
      end

      def self.upload_url(params)
        params[:upload_url]
      end

      def self.verbose(params)
        params[:verbose] ? "--verbose" : "--silent"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload builds to The Perfect App (TPA.io)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "FL_TPA_IPA",
                                       description: "Path to your IPA file. Optional if you use the `gym` or `xcodebuild` action",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end,
                                       conflicting_options: [:apk],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run")
                                       end),
          FastlaneCore::ConfigItem.new(key: :apk,
                                       env_name: "FL_TPA_APK",
                                       description: "Path to your APK file",
                                       default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH],
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find apk file at path '#{value}'") unless File.exist?(value)
                                       end,
                                       conflicting_options: [:ipa],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'apk' and '#{value.key}' options in one run")
                                       end),
          FastlaneCore::ConfigItem.new(key: :mapping,
                                       env_name: "FL_TPA_MAPPING",
                                       description: "Path to your symbols file. For iOS provide path to app.dSYM.zip. For Android provide path to mappings.txt file",
                                       default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH],
                                       optional: true,
                                       verify_block: proc do |value|
                                         # validation is done in the action
                                       end),
          FastlaneCore::ConfigItem.new(key: :upload_url,
                                       env_name: "FL_TPA_UPLOAD_URL",
                                       description: "TPA Upload URL",
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass your TPA Upload URL using `ENV['TPA_UPLOAD_URL'] = 'value'`") unless value
                                       end),
          FastlaneCore::ConfigItem.new(key: :publish,
                                       env_name: "FL_TPA_PUBLISH",
                                       description: "Publish build upon upload",
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_TPA_FORCE",
                                       description: "Should a version with the same number already exist, force the new app to take the place of the old one",
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :notes,
                                       env_name: "FL_TPA_NOTES",
                                       description: "Release notes",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_TPA_VERBOSE",
                                       description: "Detailed output",
                                       is_string: false,
                                       default_value: false,
                                       optional: true)
        ]
      end

      def self.authors
        ["mbogh"]
      end

      def self.is_supported?(platform)
        [:ios, :android].include? platform
      end
    end
  end
end
