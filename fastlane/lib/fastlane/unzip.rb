module Fastlane
  module Actions
    class UnzipAction < Action
      def self.run(params)
        require 'shellwords'

        begin
          escaped_file = params[:file].shellescape
          UI.important "🎁  Unzipping file #{escaped_file}..."

          # Base command
          command = "unzip -o #{escaped_file}"

          # Destination
          if params[:destination_path]
            escaped_destination = params[:destination_path].shellescape
            command << " -d #{escaped_destination}"
          end

          # Password
          if params[:password]
            escaped_password = params[:password].shellescape
            command << " -P #{escaped_password}"
          end

          Fastlane::Actions.sh(command, log: false)
          UI.success "Unzip finished ✅"
        rescue => ex
          UI.user_error!("Error unzipping file: #{ex}")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Extract compressed files in a ZIP"
      end

      def self.details
        [
          "unzip will extract files from a ZIP archive.",
          "The default behavior is to extract into the current directory all files from the specified ZIP archive."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file,
                                       env_name: "FL_UNZIP_FILE",
                                       description: "The path of the ZIP archive",
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :destination_path,
                                       env_name: "FL_UNZIP_DESTINATION_PATH",
                                       description: "An optional directory to which to extract files",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_UNZIP_PASSWORD",
                                       description: "The password to decrypt encrypted zipfile",
                                       optional: true)
        ]
      end

      def self.return_value
      end

      def self.authors
        ["maxoly"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
