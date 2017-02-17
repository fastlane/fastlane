module Fastlane
  module Actions
    module SharedValues
      VERSION_CODE = :VERSION_CODE
    end

    class IncrementVersionCodeAction < Action
      def self.run(params)
        path = params[:build_gradle_path] || './app/build.gradle'
        contents = File.read(path)
        new_version = 0
        new_contents = contents.gsub(/versionCode (\d*)/) do |s|
          current_version = s.match(/[0-9]+/).to_s.to_i
          version_code_param = params[:version_code] ? params[:version_code].to_i : nil
          new_version = version_code_param || current_version + 1
          "versionCode #{new_version}"
        end
        File.open(path, 'w') { |f| f.puts new_contents }

        return Actions.lane_context[SharedValues::VERSION_CODE] = new_version
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Increment the version code of your Android project'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version_code,
                                       env_name: 'FL_INCREMENT_VERSION_CODE_VERSION_CODE',
                                       description: 'Change to a specific version code',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :build_gradle_path,
                                       env_name: 'FL_INCREMENT_VERSION_CODE_BUILD_GRADLE_PATH',
                                       description: 'Path to the project build.gradle',
                                       optional: true)
        ]
      end

      def self.output
        [
          ['VERSION_CODE', 'The new version code']
        ]
      end

      def self.return_value
        'The new version code'
      end

      def self.authors
        ['mandybess', 'jamescmartinez']
      end

      def self.is_supported?(platform)
        platform == :android
      end

      def self.category
        :project
      end
    end
  end
end
