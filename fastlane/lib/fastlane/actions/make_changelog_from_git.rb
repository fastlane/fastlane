module Fastlane
  module Actions
    module SharedValues
      MAKE_CHANGELOG_FROM_GIT_FILE_PATH = :MAKE_CHANGELOG_FROM_GIT_FILE_PATH
    end

    class MakeChangelogFromGitAction < Action
      def self.run(params)
        infoFile = params[:appInfoFile]

        # Reading Bundle Version and Build Number from Info.plist file if it was provided
        if infoFile.nil? || infoFile.empty?
          bundleVersion = buildNumber = "[Property :appInfoFile is not specified!]"
        else
          bundleVersion = %x[defaults read "#{File.expand_path(infoFile).chomp('.plist')}" CFBundleShortVersionString]
          bundleVersion = bundleVersion.gsub(/\s+/, "")
          exit $? >> 8 if bundleVersion == ''

          buildNumber = %x[defaults read "#{File.expand_path(infoFile).chomp('.plist')}" CFBundleVersion]
          buildNumber = buildNumber.gsub(/\s+/, "")
          exit $? >> 8 if buildNumber == ''
        end

        # Retrieving and formatting logs
        logFormat = params[:logFormat]
        numberOfLogLines = params[:numberOfLogLines]
        gitLog = %x[git log --pretty=format:"#{logFormat}" -#{numberOfLogLines}]
        logLimiter = params[:logLimiter]
        indexOfLogLimiter = gitLog.index(logLimiter)
        relevantGitLog = indexOfLogLimiter && indexOfLogLimiter != 0 ? gitLog.slice(0..indexOfLogLimiter - 2) : gitLog

        template = params[:template]

        if (infoFile.nil? || infoFile.empty?) && (template.index('$bundleVersion') || template.index('$bundleVersion'))
          Helper.log.info "$bundleVersion or $bundleVersion is used in template, but :appInfoFile property is not set!"
        end

        template = template.sub('$bundleVersion', bundleVersion)
        template = template.sub('$buildNumber', buildNumber)
        template = template.sub('$changelog', relevantGitLog)

        if params[:showChangelog]
          Helper.log.info "Writing in Changelog file:"
          Helper.log.info "#{template}"
        end

        # Writing result changelog in file
        File.open(params[:changelogFilePath], 'w') {
          |file| file.write(template)
        }

        Helper.log.info "Changelog file is written."

        # Storing result file path in case other actions use it
        Actions.lane_context[SharedValues::MAKE_CHANGELOG_FROM_GIT_FILE_PATH] = params[:changelogFilePath]
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Generates file with release notes gathered from git"
      end

      def self.details
        "You can use this action to gather list of changes from git and save it to the file"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :changelogFilePath,
                                       env_name: "FL_MAKE_CHANGELOG_FROM_GIT_FILE_PATH",
                                       description: "File path to release notes file",
                                       is_string: true,
                                       default_value: "fastlane/ReleaseNotes.txt"),
          FastlaneCore::ConfigItem.new(key: :appInfoFile,
                                       env_name: "FL_MAKE_CHANGELOG_FROM_GIT_APP_INFO_FILE",
                                       description: "Application info.plist file path ",
                                       is_string: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :template,
                                       env_name: "FL_MAKE_CHANGELOG_FROM_GIT_TEMPLATE",
                                       description: "Template for release notes. Use next variables: $bundleVersion, $buildNumber, $relevantGitLog",
                                       is_string: true,
                                       default_value: "What\'s new in v$bundleVersion ($buildNumber):\n$changelog\n"),
          FastlaneCore::ConfigItem.new(key: :logFormat,
                                       env_name: "FL_MAKE_CHANGELOG_FROM_GIT_LOG_FORMAT_STRING",
                                       description: "GIT log pretty format. For help see: https://git-scm.com/docs/pretty-formats",
                                       is_string: true,
                                       default_value: "- %s (%an)"),
          FastlaneCore::ConfigItem.new(key: :logLimiter,
                                       env_name: "FL_MAKE_CHANGELOG_FROM_GIT_LOG_LIMITER",
                                       description: "Commit name in log that can serve as separator for changelog",
                                       is_string: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :numberOfLogLines,
                                       env_name: "FL_MAKE_CHANGELOG_FROM_GIT_NUMBER_OF_LOG_LINES",
                                       description: "Number of lines from GIT you want to put into changelog file. It can be additionally limited by logLimiter property",
                                       is_string: false,
                                       default_value: 20),
          FastlaneCore::ConfigItem.new(key: :showChangelog,
                                       env_name: "FL_MAKE_CHANGELOG_FROM_GIT_SHOW_CHANGELOG",
                                       description: "Show what will be written to changelog file in logs",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.output
        [
          ['MAKE_CHANGELOG_FROM_GIT_FILE_PATH', 'Changelog file path']
        ]
      end

      def self.return_value   
      end

      def self.authors
        ["yuriy-tolstoguzov"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
