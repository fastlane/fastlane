module Fastlane
  class CrashlyticsBeta
    def initialize(beta_info, ui)
      @beta_info = beta_info
      @ui = ui
    end

    def run
      setup = Setup.new

      @ui.message('This command will generate a fastlane configuration for distributing your app with Beta by Crashlytics')
      @ui.message('so that you can get your testers new builds with a single command!')

      @ui.message('')

      if setup.is_android?
        UI.user_error!('Sorry, Beta by Crashlytics configuration is currently only available for iOS projects!')
      elsif !setup.is_ios?
        UI.user_error!('Please run Beta by Crashlytics configuration from your iOS project folder.')
      end

      @ui.message("\nAttempting to detect your project settings in this directory...".cyan)
      info_collector = CrashlyticsBetaInfoCollector.new(CrashlyticsProjectParser.new,
                                                        CrashlyticsBetaUserEmailFetcher.new,
                                                        @ui)
      info_collector.collect_info_into(@beta_info)

      if FastlaneCore::FastlaneFolder.setup?
        @ui.message("")
        @ui.header('Copy and paste the following lane into your Fastfile to use Crashlytics Beta!')
        @ui.message("")
        puts(lane_template.cyan)
        @ui.message("")
      else
        fastfile = fastfile_template
        FileUtils.mkdir_p('fastlane')
        File.write('fastlane/Fastfile', fastfile)
        @ui.success('A Fastfile has been generated for you at ./fastlane/Fastfile 🚀')
      end
      @ui.header('Next Steps')
      @ui.success('Run the following command to build and upload to Beta by Crashlytics. 🎯')
      @ui.message("\n    fastlane beta")
      @ui.message("")
    end

    def lane_template
      discovered_crashlytics_path = Fastlane::Helper::CrashlyticsHelper.discover_default_crashlytics_path

      unless expanded_paths_equal?(@beta_info.crashlytics_path, discovered_crashlytics_path)
        crashlytics_path_arg = "\n         crashlytics_path: '#{@beta_info.crashlytics_path}',"
      end

      beta_info_groups = @beta_info.groups_valid? ? "['#{@beta_info.groups.join("', '")}']" : "nil"
      beta_info_emails = @beta_info.emails_valid? ? "['#{@beta_info.emails.join("', '")}']" : "nil"

# rubocop:disable Layout/IndentationConsistency
%{  #
  # Learn more here: https://docs.fastlane.tools/getting-started/ios/beta-deployment/
  #             and: https://docs.fastlane.tools/getting-started/android/beta-deployment/
  #
  lane :beta do |values|
    # Fabric generated this lane for deployment to Crashlytics Beta
    # set 'export_method' to 'ad-hoc' if your Crashlytics Beta distribution uses ad-hoc provisioning
    build_app(scheme: '#{@beta_info.schemes.first}', export_method: '#{@beta_info.export_method}')

    emails = values[:test_email] ? values[:test_email] : #{beta_info_emails} # You can list more emails here
    groups = values[:test_email] ? nil : #{beta_info_groups} # You can define groups on the web and reference them here

    crashlytics(api_token: '#{@beta_info.api_key}',
             build_secret: '#{@beta_info.build_secret}',#{crashlytics_path_arg}
                   emails: emails,
                   groups: groups,
                    notes: 'Distributed with fastlane', # Check out the changelog_from_git_commits action
            notifications: true) # Should this distribution notify your testers via email?

    # for all available options run `fastlane action crashlytics`

    # You can notify your team in chat that a beta build has been uploaded
    # slack(
    #   slack_url: "https://hooks.slack.com/services/YOUR/TEAM/INFO"
    #   channel: "beta-releases",
    #   message: "Successfully uploaded a beta release - see it at https://fabric.io/_/beta"
    # )
  end}
      # rubocop:enable Layout/IndentationConsistency
    end

    def expanded_paths_equal?(path1, path2)
      return nil if path1.nil? || path2.nil?

      File.expand_path(path1) == File.expand_path(path2)
    end

    def fastfile_template
      <<-eos
fastlane_version "#{Fastlane::VERSION}"

default_platform :ios

platform :ios do
#{lane_template}
end
eos
    end
  end
end
