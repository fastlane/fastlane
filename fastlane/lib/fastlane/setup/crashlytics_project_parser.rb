require 'xcodeproj'

module Fastlane
  class CrashlyticsProjectParser
    attr_accessor :api_key
    attr_accessor :build_secret

    # @param project_file_path path to a .xcodeproj file
    def initialize(target_name, project_file_path)
      parse(target_name, project_file_path)
    end

    def values_found?
      !api_key.nil? && !build_secret.nil?
    end

    def parse(target_name, project_file_path)
      # target_name = project.default_build_settings(key: 'TARGETNAME')
      # path = project.is_workspace ? project.path.gsub('xcworkspace', 'xcodeproj') : project.path

      # TODO decide how to handle errors
      UI.crash!("No project available at path #{project_file_path}") unless File.exist?(project_file_path)

      xcode_project = Xcodeproj::Project.open(project_file_path)
      target = xcode_project.targets.find { |t| t.name == target_name }

      # TODO decide how to handle errors
      UI.crash!("Unable to locate a target by the name of #{target_name}") if target.nil?

      scripts = target.build_phases.select { |t| t.class == Xcodeproj::Project::Object::PBXShellScriptBuildPhase }
      crash_script = scripts.find { |s| includes_run_script?(s.shell_script) }

      # TODO decide how to handle errors
      UI.user_error!("Unable to find Crashlytics Run Script Build Phase") if crash_script.nil?

      script_array = crash_script.shell_script.split('\n').find { |line| includes_run_script?(line) }.split(' ')

      if script_array.count == 3 && api_key_valid?(script_array[1]) && build_secret_valid?(script_array[2])
        @api_key = script_array[1]
        @build_secret = script_array[2]
      end
    end

    def api_key_valid?(key)
      key.to_s.length == 40
    end

    def build_secret_valid?(secret)
      secret.to_s.length == 64
    end

    def includes_run_script?(string)
      ['Fabric/run', 'Crashlytics/run', 'Fabric.framework/run', 'Crashlytics.framework/run'].any? do |script_path_fragment|
        string.include?(script_path_fragment)
      end
    end
  end
end
