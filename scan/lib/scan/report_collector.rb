module Scan
  class ReportCollector
    SUPPORTED = %w(html junit json-compilation-database)

    # Intialize with values from Scan.config matching these param names
    def initialize(open_report, output_types, output_directory, use_clang_report_name, custom_report_file_name = nil)
      @open_report = open_report
      @output_types = output_types
      @output_directory = output_directory
      @use_clang_report_name = use_clang_report_name
      @custom_report_file_name = custom_report_file_name
    end

    def parse_raw_file(path)
      UI.user_error!("Couldn't find file at path '#{path}'") unless File.exist?(path)

      commands = generate_commands(path)
      commands.each do |output_path, command|
        if system(command)
          UI.success("Successfully generated report at '#{output_path}'")
        else
          UI.user_error!("Failed to generate report at '#{output_path}'")
        end

        if @open_report and output_path.end_with?(".html")
          # Open the HTML file
          `open --hide '#{output_path}'`
        end
      end
    end

    # Returns a hash containing the resulting path as key and the command as value
    def generate_commands(path, types: nil, output_file_name: nil)
      types ||= @output_types
      types = types.split(",") if types.kind_of?(String) # might already be an array when passed via fastlane
      commands = {}

      types.each do |raw|
        type = raw.strip

        unless SUPPORTED.include?(type)
          UI.error("Couldn't find reporter '#{type}', available #{SUPPORTED.join(', ')}")
          next
        end

        output_path = output_file_name || File.join(File.expand_path(@output_directory), determine_output_file_name(type))

        parts = ["cat '#{path}' | "]
        parts << "xcpretty"
        parts << "--report #{type}"
        parts << "--output '#{output_path}'"
        parts << "&> /dev/null "

        commands[output_path] = parts.join(" ")
      end

      return commands
    end

    def determine_output_file_name(type)
      if @use_clang_report_name && type == "json-compilation-database"
        "compile_commands.json"
      elsif !@custom_report_file_name.nil?
        @custom_report_file_name
      else
        "report.#{type}"
      end
    end
  end
end
