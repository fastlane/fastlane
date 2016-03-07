module Fastlane
  module Actions
    class LcovAction < Action

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.run(options)
        unless Helper.test?
          raise 'lcov not installed, please install using `brew install lcov`'.red if `which lcov`.length == 0
        end
        gen_cov(options)
      end

      def self.description
        "Generates coverage data using lcov"
      end

      def self.available_options
        [

          FastlaneCore::ConfigItem.new(key: :project_name,
                                       env_name: "FL_LCOV_PROJECT_NAME",
                                       description: "Name of the project"),

          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: "FL_LCOV_SCHEME",
                                       description: "Scheme of the project"),

          FastlaneCore::ConfigItem.new(key: :arch,
                                       env_name: "FL_LCOV_ARCH",
                                       description: "The build arch where will search .gcda files",
                                       default_value: "i386"),

          FastlaneCore::ConfigItem.new(key: :output_dir,
                                       env_name: "FL_LCOV_OUTPUT_DIR",
                                       description: "The output directory that coverage data will be stored. If not passed will use coverage_reports as default value",
                                       optional: true,
                                       is_string: true,
                                       default_value: "coverage_reports")
        ]
      end

      def self.author
        "thiagolioy"
      end

      def self.gen_cov(options)
        tmp_cov_file = "/tmp/coverage.info"
        output_dir = options[:output_dir]
        derived_data_path = derived_data_dir(options)

        system("lcov --capture --directory \"#{derived_data_path}\" --output-file #{tmp_cov_file}")
        system(gen_lcov_cmd(tmp_cov_file))
        system("genhtml #{tmp_cov_file} --output-directory #{output_dir}")
      end

      def self.gen_lcov_cmd(cov_file)
        cmd = "lcov "
        exclude_dirs.each do |e|
          cmd << "--remove #{cov_file} \"#{e}\" "
        end
        cmd << "--output #{cov_file} "
      end

      def self.derived_data_dir(options)
        pn = options[:project_name]
        sc = options[:scheme]
        arch = options[:arch]

        initial_path = "#{Dir.home}/Library/Developer/Xcode/DerivedData/"
        end_path = "/Build/Intermediates/#{pn}.build/Debug-iphonesimulator/#{sc}.build/Objects-normal/#{arch}/"

        match = find_project_dir(pn, initial_path)

        "#{initial_path}#{match}#{end_path}"
      end

      def self.find_project_dir(project_name, path)
        `ls -t #{path}| grep #{project_name} | head -1`.to_s.gsub(/\n/, "")
      end

      def self.exclude_dirs
        ["/Applications/*", "/Frameworks/*"]
      end

    end
  end
end
