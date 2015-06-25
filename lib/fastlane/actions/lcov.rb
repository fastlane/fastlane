module Fastlane
  module Actions
    class LcovAction < Action
      @@derived_data_path = "#{File.expand_path('~')}/Library/Developer/Xcode/DerivedData/"
      @@out_cov_file = "/tmp/coverage.info"
      @@exclude_dirs = ["/Applications/*","/Frameworks/*"]

      def self.is_supported?(platform)
        true
      end

      def self.run(options)
        unless Helper.test?
          raise 'lcov not installed, please install using `brew install lcov`'.red if `which lcov`.length == 0
        end
        handle_exceptions(options)
        gen_cov(options)
      end

      def self.description
        "Generates coverage data using lcov"
      end

      def self.available_options
        [

          FastlaneCore::ConfigItem.new(key: :project_name,
                                       env_name: "PROJECT_NAME",
                                       description: "Name of the project"),

          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: "SCHEME",
                                       description: "Scheme of the project"),

          FastlaneCore::ConfigItem.new(key: :output_dir,
                                       env_name: "OUTPUT_DIR",
                                       description: "The output directory that coverage data will be stored. If not passed will use coverage_reports as default value",
                                       optional: true,
                                       is_string: true,
                                       default_value: "coverage_reports")


        ]
      end

      def self.author
        "thiagolioy"
      end

      private
      def self.handle_exceptions(options)
          unless (options[:project_name] rescue nil)
            Helper.log.fatal "Please add 'ENV[\"PROJECT_NAME\"] = \"a_valid_project_name\"' to your Fastfile's `before_all` section.".red
            raise 'No PROJECT_NAME given.'.red
          end

          unless (options[:scheme] rescue nil)
            Helper.log.fatal "Please add 'ENV[\"SCHEME\"] = \"a_valid_scheme\"' to your Fastfile's `before_all` section.".red
            raise 'No SCHEME given.'.red
          end
      end

      def self.gen_cov(options)
        system("lcov --capture --directory \"#{derived_data_dir(options)}\" --output-file #{@@out_cov_file}")
        cmd = "lcov "
        @@exclude_dirs.each do |e|
          cmd << "--remove #{@@out_cov_file} \"#{e}\" "
        end
        cmd << "--output #{@@out_cov_file} "
        system(cmd)
        system("genhtml #{@@out_cov_file} --output-directory #{options[:output_dir]}")
      end


      def self.derived_data_dir(options)
         match = `ls -t #{@@derived_data_path}| grep #{options[:project_name]} | head -1`.to_s.gsub(/\n/, "")
         derived_data_end_path = "/Build/Intermediates/#{options[:project_name]}.build/Debug-iphonesimulator/#{options[:scheme]}.build/Objects-normal/i386/"
         "#{@@derived_data_path}#{match}#{derived_data_end_path}"
      end

    end
  end
end
