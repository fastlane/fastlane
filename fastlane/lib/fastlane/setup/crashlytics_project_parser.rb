require 'xcodeproj'

module Fastlane
  class CrashlyticsProjectParser
    # @param project_file_path path to a .xcodeproj file
    def initialize(target_name, project_file_path)
      @target_name = target_name
      @project_file_path = project_file_path
    end

    def parse
      # TODO decide how to handle errors
      UI.crash!("No project available at path #{@project_file_path}") unless File.exist?(@project_file_path)

      xcode_project = Xcodeproj::Project.open(@project_file_path)
      target = xcode_project.targets.find { |t| t.name == @target_name }

      # TODO decide how to handle errors
      UI.crash!("Unable to locate a target by the name of #{@target_name}") if target.nil?

      scripts = target.build_phases.select { |t| t.class == Xcodeproj::Project::Object::PBXShellScriptBuildPhase }
      crash_script = scripts.find { |s| includes_run_script?(s.shell_script) }

      # TODO decide how to handle errors
      UI.user_error!("Unable to find Crashlytics Run Script Build Phase") if crash_script.nil?

      script_array = crash_script.shell_script.split('\n').find { |line| includes_run_script?(line) }.split(' ')

      if script_array.count == 3
        {
          api_key: script_array[1],
          build_secret: script_array[2]
        }
      end
    end

    def includes_run_script?(string)
      ['Fabric/run', 'Crashlytics/run', 'Fabric.framework/run', 'Crashlytics.framework/run'].any? do |script_path_fragment|
        string.include?(script_path_fragment)
      end
    end
  end
end
