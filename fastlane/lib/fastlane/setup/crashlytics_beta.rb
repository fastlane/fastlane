module Fastlane
  class CrashlyticsBeta
    def initialize(beta_info)
      @beta_info = beta_info
    end

    def run
      UI.user_error!('Beta by Crashlytics configuration is currently only available for iOS projects.') unless Setup.new.is_ios?
      config = {}
      FastlaneCore::Project.detect_projects(config)
      project = FastlaneCore::Project.new(config)
      scheme = project.schemes.first

      target_name = project.default_build_settings(key: 'TARGETNAME')
      project_file_path = project.is_workspace ? project.path.gsub('xcworkspace', 'xcodeproj') : project.path

      project_parser = Fastlane::CrashlyticsProjectParser.new(target_name, project_file_path)

      info_collector = Fastlane::CrashlyticsBetaInfoCollector.new(project_parser)
      info_collector.collect_info_into(@beta_info)

      if FastlaneFolder.setup?
        UI.message ""
        UI.header('Copy and paste the following lane into your Fastfile to use Crashlytics Beta!')
        puts lane_template(scheme).cyan
      else
        fastfile = fastfile_template(scheme)
        FileUtils.mkdir_p('fastlane')
        File.write('fastlane/Fastfile', fastfile)
        UI.success('A Fastfile has been generated for you at ./fastlane/Fastfile 🚀')
      end
      UI.message ""
      UI.header('Next Steps')
      UI.success('Run `fastlane beta` to build and upload to Beta by Crashlytics. 🎯')
      UI.success('After submitting your beta, visit https://fabric.io/_/beta to add release notes and notify testers.')
      UI.success('You can edit your Fastfile to distribute and notify testers automatically.')
      UI.success('Learn more here: https://github.com/fastlane/setups/blob/master/samples-ios/distribute-beta-build.md 🚀')
    end

    def lane_template(scheme)
      %{
  lane :beta do
    # set 'export_method' to 'ad-hoc' if your Crashlytics Beta distribution uses ad-hoc provisioning
    gym(scheme: '#{scheme}', export_method: 'development')
    crashlytics(api_token: '#{@beta_info.api_key}',
             build_secret: '#{@beta_info.build_secret}',
            notifications: true
              )
  end
      }
    end

    def fastfile_template(scheme)
      <<-eos
fastlane_version "#{Fastlane::VERSION}"
default_platform :ios
platform :ios do
  lane :beta do
    # set 'export_method' to 'ad-hoc' if your Crashlytics Beta distribution uses ad-hoc provisioning
    gym(scheme: '#{scheme}', export_method: 'development')
    crashlytics(api_token: '#{@beta_info.api_key}',
             build_secret: '#{@beta_info.build_secret}',
            notifications: true
            )
  end
end
eos
    end
  end
end
