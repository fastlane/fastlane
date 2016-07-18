module Fastlane
  class CrashlyticsBeta
    def run
      UI.user_error!('Beta by Crashlytics configuration is currently only available for iOS projects.') unless Setup.new.is_ios?
      config = {}
      FastlaneCore::Project.detect_projects(config)
      project = FastlaneCore::Project.new(config)
      keys = keys_from_project(project)

      if FastlaneFolder.setup?
        UI.header('Copy and paste the following lane into your Fastfile to use Crashlytics Beta!')
        puts lane_template(keys[:api_key], keys[:build_secret], project.schemes.first).cyan
      else
        fastfile = fastfile_template(keys[:api_key], keys[:build_secret], project.schemes.first)
        FileUtils.mkdir_p('fastlane')
        File.write('fastlane/Fastfile', fastfile)
        UI.success('A Fastfile has been generated for you at ./fastlane/Fastfile 🚀')
      end
      UI.header('Next Steps')
      UI.success('Run `fastlane beta` to build and upload to Beta by Crashlytics. 🎯')
      UI.success('After submitting your beta, visit https://fabric.io/_/beta to add release notes and notify testers.')
      UI.success('You can edit your Fastfile to distribute and notify testers automatically.')
      UI.success('Learn more here: https://github.com/fastlane/setups/blob/master/samples-ios/distribute-beta-build.md 🚀')
    end

    def keys_from_project(project)
      require 'xcodeproj'
      target_name = project.default_build_settings(key: 'TARGETNAME')
      path = project.is_workspace ? project.path.gsub('xcworkspace', 'xcodeproj') : project.path
      UI.crash!("No project available at path #{path}") unless File.exist?(path)
      xcode_project = Xcodeproj::Project.open(path)
      target = xcode_project.targets.find { |t| t.name == target_name }
      UI.crash!("Unable to locate a target by the name of #{target_name}") if target.nil?
      scripts = target.build_phases.select { |t| t.class == Xcodeproj::Project::Object::PBXShellScriptBuildPhase }
      crash_script = scripts.find { |s| includes_run_script?(s.shell_script) }
      UI.user_error!("Unable to find Crashlytics Run Script Build Phase") if crash_script.nil?
      script_array = crash_script.shell_script.split('\n').find { |l| includes_run_script?(l) }.split(' ')
      if script_array.count == 3 && api_key_valid?(script_array[1]) && build_secret_valid?(script_array[2])
        {
          api_key: script_array[1],
          build_secret: script_array[2]
        }
      else
        UI.important('fastlane was unable to detect your Fabric API Key and Build Secret. 🔑')
        UI.important('Navigate to https://www.fabric.io/settings/organizations, select the appropriate organization,')
        UI.important('and copy the API Key and Build Secret.')
        keys = {}
        loop do
          keys[:api_key] = UI.input('API Key:')
          break if api_key_valid?(keys[:api_key])
          UI.important "Invalid API Key, Please Try Again!"
        end
        loop do
          keys[:build_secret] = UI.input('Build Secret:')
          break if build_secret_valid?(keys[:build_secret])
          UI.important "Invalid Build Secret, Please Try Again!"
        end
        keys
      end
    end

    def api_key_valid?(key)
      key.to_s.length == 40
    end

    def build_secret_valid?(secret)
      secret.to_s.length == 64
    end

    def includes_run_script?(string)
      string.include?('Fabric/run') || string.include?('Crashlytics/run') || string.include?('Fabric.framework/run') || string.include?('Crashlytics.framework/run')
    end

    def lane_template(api_key, build_secret, scheme)
      %{
  lane :beta do
    # set 'export_method' to 'ad-hoc' if your Crashlytics Beta distribution uses ad-hoc provisioning
    gym(scheme: '#{scheme}', export_method: 'development')
    crashlytics(api_token: '#{api_key}',
             build_secret: '#{build_secret}',
            notifications: true
              )
  end
      }
    end

    def fastfile_template(api_key, build_secret, scheme)
      <<-eos
fastlane_version "#{Fastlane::VERSION}"
default_platform :ios
platform :ios do
  lane :beta do
    # set 'export_method' to 'ad-hoc' if your Crashlytics Beta distribution uses ad-hoc provisioning
    gym(scheme: '#{scheme}', export_method: 'development')
    crashlytics(api_token: '#{api_key}',
             build_secret: '#{build_secret}',
            notifications: true
            )
  end
end
eos
    end
  end
end
