module Fastlane
  module Actions
    class ClocAction < Action
      def self.run(params)
        cloc_binary = params[:binary_path]
        exclude_dirs = params[:exclude_dir].nil? ? '' : "--exclude-dir=#{params[:exclude_dir]}"
        xml_format = params[:xml]
        out_dir = params[:output_directory]
        output_file = xml_format ? "#{out_dir}/cloc.xml" : "#{out_dir}/cloc.txt"
        source_directory = params[:source_directory]

        command = [
          cloc_binary,
          exclude_dirs,
          '--by-file',
          xml_format ? '--xml ' : '',
          "--out=#{output_file}",
          source_directory
        ].join(' ').strip

        Actions.sh(command)
      end

      def self.description
        "Generates a Code Count that can be read by Jenkins (xml format)"
      end

      def self.details
        [
          "This action will run cloc to generate a SLOC report that the Jenkins SLOCCount plugin can read.",
          "See https://wiki.jenkins-ci.org/display/JENKINS/SLOCCount+Plugin and https://github.com/AlDanial/cloc for more information."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :binary_path,
                                       env_name: "FL_CLOC_BINARY_PATH",
                                       description: "Where the cloc binary lives on your system (full path including 'cloc')",
                                       optional: true,
                                       is_string: true,
                                       default_value: '/usr/local/bin/cloc'),
          FastlaneCore::ConfigItem.new(key: :exclude_dir,
                                       env_name: "FL_CLOC_EXCLUDE_DIR",
                                       description: "Comma separated list of directories to exclude", # a short description of this parameter
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :output_directory,
                                       env_name: "FL_CLOC_OUTPUT_DIRECTORY",
                                       description: "Where to put the generated report file",
                                       is_string: true,
                                       default_value: "build"),
          FastlaneCore::ConfigItem.new(key: :source_directory,
                                      env_name: "FL_CLOC_SOURCE_DIRECTORY",
                                      description: "Where to look for the source code (relative to the project root folder)",
                                      is_string: true,
                                      default_value: ""),
          FastlaneCore::ConfigItem.new(key: :xml,
                                      env_name: "FL_CLOC_XML",
                                      description: "Should we generate an XML File (if false, it will generate a plain text file)?",
                                      is_string: false,
                                      default_value: true)
        ]
      end

      def self.authors
        ["intere"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'cloc(
             exclude_dir: "ThirdParty,Resources",
             output_directory: "reports",
             source_directory: "MyCoolApp"
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
