require 'xcodeproj'

module Fastlane
  class CrashlyticsProjectParser
    # @param project_file_path path to a .xcodeproj file
    def initialize(config = {})
      FastlaneCore::Project.detect_projects(config)
      @project = FastlaneCore::Project.new(config, xcodebuild_list_silent: true, xcodebuild_suppress_stderr: true)

      @target_name = @project.default_build_settings(key: 'TARGETNAME')
      @project_file_path = @project.is_workspace ? @project.path.gsub('xcworkspace', 'xcodeproj') : @project.path
    end

    def parse
      results = {
        schemes: @project.schemes
      }

      xcode_project = Xcodeproj::Project.open(@project_file_path)
      target = xcode_project.targets.find { |t| t.name == @target_name }

      UI.crash!("Unable to locate a target by the name of #{@target_name}") if target.nil?

      scripts = target.build_phases.select { |t| t.class == Xcodeproj::Project::Object::PBXShellScriptBuildPhase }
      crash_script = scripts.find { |s| includes_run_script?(s.shell_script) }

      UI.user_error!("Unable to find Crashlytics Run Script Build Phase") if crash_script.nil?

      script_array = crash_script.shell_script.split('\n').find { |line| includes_run_script?(line) }.split(' ')
      if script_array.count == 3
        results.merge!({
          # The run script build phase probably refers to Fabric.framework/run, but the submit binary
          # only lives in the Crashlytics.framework, so we'll substitute and try to resolve it that way.
          crashlytics_path: File.dirname(script_array[0].gsub("Fabric.framework", "Crashlytics.framework")),
          api_key: script_array[1],
          build_secret: script_array[2]
        })
      end

      results
    end

    def includes_run_script?(string)
      ['Fabric/run', 'Crashlytics/run', 'Fabric.framework/run', 'Crashlytics.framework/run'].any? do |script_path_fragment|
        string.include?(script_path_fragment)
      end
    end
  end
end
