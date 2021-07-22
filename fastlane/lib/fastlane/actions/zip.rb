module Fastlane
  module Actions
    class ZipAction < Action
      class Runner
        attr_reader :output_path, :path, :verbose, :password, :symlinks

        def initialize(params)
          @output_path = File.expand_path(params[:output_path] || params[:path])
          @path = params[:path]
          @verbose = params[:verbose]
          @password = params[:password]
          @symlinks = params[:symlinks]

          @output_path += ".zip" unless @output_path.end_with?(".zip")
        end

        def run
          UI.message("Compressing #{path}...")

          create_output_dir
          run_zip_command

          UI.success("Successfully generated zip file at path '#{output_path}'")
          output_path
        end

        def create_output_dir
          output_dir = File.expand_path("..", output_path)
          FileUtils.mkdir_p(output_dir)
        end

        def run_zip_command
          # The 'zip' command archives relative to the working directory, chdir to produce expected results relative to `path`
          Dir.chdir(File.expand_path("..", path)) do
            Actions.sh(zip_command)
          end
        end

        def zip_command
          zip_options = verbose ? "r" : "rq"
          zip_options += "y" if symlinks

          command = ["zip", "-#{zip_options}"]

          if password
            command << "-P"
            command << password
          end

          command << output_path
          command << File.basename(path)

          command
        end
      end
      def self.run(params)
        Runner.new(params).run
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Compress a file or folder to a zip"
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
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_ZIP_VERBOSE",
                                       description: "Enable verbose output of zipped file",
                                       default_value: true,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_ZIP_PASSWORD",
                                       description: "Encrypt the contents of the zip archive using a password",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :symlinks,
                                       env_name: "FL_ZIP_SYMLINKS",
                                       description: "Store symbolic links as such in the zip archive",
                                       optional: true,
                                       type: Boolean,
                                       default_value: false)
        ]
      end

      def self.example_code
        [
          'zip',
          'zip(
            path: "MyApp.app",
            output_path: "Latest.app.zip"
          )',
          'zip(
            path: "MyApp.app",
            output_path: "Latest.app.zip",
            verbose: false
          )',
          'zip(
            path: "MyApp.app",
            output_path: "Latest.app.zip",
            verbose: false,
            symlinks: true
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

      def self.return_type
        :string
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
