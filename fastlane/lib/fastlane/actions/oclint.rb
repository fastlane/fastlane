module Fastlane
  module Actions
    module SharedValues
      FL_OCLINT_REPORT_PATH = :FL_OCLINT_REPORT_PATH
    end

    class OclintAction < Action
      def self.run(params)
        select_reqex = params[:select_reqex]

        compile_commands = params[:compile_commands]
        raise "Could not find json compilation database at path '#{compile_commands}'".red unless File.exist?(compile_commands)

        files = JSON.parse(File.read(compile_commands)).map { |compile_command| compile_command['file'] }
        files.uniq!
        files.select! do |file|
          file_ruby = file.gsub('\ ', ' ')
          File.exist?(file_ruby) and (!select_reqex or file_ruby =~ select_reqex)
        end

        command_prefix = [
          'cd',
          File.expand_path('.').shellescape,
          '&&'
        ].join(' ')

        report_type = params[:report_type]
        report_path = params[:report_path] ? params[:report_path] : 'oclint_report.' + report_type

        oclint_args = ["-report-type=#{report_type}", "-o=#{report_path}"]
        oclint_args << "-rc=#{params[:rc]}" if params[:rc]
        oclint_args << "-max-priority-1=#{params[:max_priority_1]}" if params[:max_priority_1]
        oclint_args << "-max-priority-2=#{params[:max_priority_2]}" if params[:max_priority_2]
        oclint_args << "-max-priority-3=#{params[:max_priority_3]}" if params[:max_priority_3]

        command = [
          command_prefix,
          'oclint',
          oclint_args,
          '"' + files.join('" "') + '"'
        ].join(' ')

        Action.sh command

        Actions.lane_context[SharedValues::FL_OCLINT_REPORT_PATH] = File.expand_path(report_path)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Lints implementation files with OCLint"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :compile_commands,
                                       env_name: 'FL_OCLINT_COMPILE_COMMANDS',
                                       description: 'The json compilation database, use xctool reporter \'json-compilation-database\'',
                                       default_value: 'compile_commands.json',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :select_reqex,
                                       env_name: 'FL_OCLINT_SELECT_REQEX',
                                       description: 'Select all files matching this reqex',
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :report_type,
                                       env_name: 'FL_OCLINT_REPORT_TYPE',
                                       description: 'The type of the report (default: html)',
                                       default_value: 'html',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :report_path,
                                       env_name: 'FL_OCLINT_REPORT_PATH',
                                       description: 'The reports file path',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :rc,
                                       env_name: 'FL_OCLINT_RC',
                                       description: 'Override the default behavior of rules',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :max_priority_1,
                                       env_name: 'FL_OCLINT_MAX_PRIOTITY_1',
                                       description: 'The max allowed number of priority 1 violations',
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :max_priority_2,
                                       env_name: 'FL_OCLINT_MAX_PRIOTITY_2',
                                       description: 'The max allowed number of priority 2 violations',
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :max_priority_3,
                                       env_name: 'FL_OCLINT_MAX_PRIOTITY_3',
                                       description: 'The max allowed number of priority 3 violations',
                                       is_string: false,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['FL_OCLINT_REPORT_PATH', 'The reports file path']
        ]
      end

      def self.author
        'HeEAaD'
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
