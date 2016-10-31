module Fastlane
  module Actions
    class ZipAction < Action
      def self.run(params)
        UI.message "Compressing #{params[:path]}..."

        params[:output_path] ||= "#{params[:path]}.zip"

        Dir.chdir(File.expand_path("..", params[:path])) do # required to properly zip
          Actions.sh "zip -r #{params[:output_path].shellescape} #{File.basename(params[:path]).shellescape}"
        end

        UI.success "Successfully generated zip file at path '#{File.expand_path(params[:output_path])}'"
        return File.expand_path(params[:output_path])
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Compress a file or folder to a zip"
      end

      def self.details
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_ZIP_PATH",
                                       description: "Path to the directory or file to be zipped",
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file/folder at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                       env_name: "FL_ZIP_OUTPUT_NAME",
                                       description: "The name of the resulting zip file",
                                       optional: true)
        ]
      end

      def self.example_code
        [
          'zip',
          'zip(
            path: "MyApp.app",
            output_path: "Latest.app.zip"
          )'
        ]
      end

      def self.category
        :misc
      end

      def self.output
        []
      end

      def self.return_value
        "The path to the output zip file"
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
