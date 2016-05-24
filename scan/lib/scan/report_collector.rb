module Scan
  class ReportCollector
    SUPPORTED = %w(html junit json-compilation-database)

    # Intialize with values from Scan.config matching these param names
    def initialize(open_report, output_types, output_directory, clang_report_name)
      @open_report = open_report
      @output_types = output_types
      @output_directory = output_directory
      @clang_report_name = clang_report_name
    end

    def parse_raw_file(path)
      UI.user_error!("Couldn't find file at path '#{path}'") unless File.exist?(path)

      commands = generate_commands(path)
      commands.each do |output_path, command|
        system(command)
        UI.success("Successfully generated report at '#{output_path}'")

        if @open_report and output_path.end_with?(".html")
          # Open the HTML file
          `open --hide '#{output_path}'`
        end
      end
    end

    # Returns a hash containg the resulting path as key and the command as value
    def generate_commands(path, types: nil, output_file_name: nil)
      use_clang_naming ||= @clang_report_name
      types ||= @output_types
      types = types.split(",") if types.kind_of?(String) # might already be an array when passed via fastlane
      commands = {}

      types.each do |raw|
        type = raw.strip

        unless SUPPORTED.include?(type)
          UI.error("Couldn't find reporter '#{type}', available #{SUPPORTED.join(', ')}")
          next
        end

        file_name = "report.#{type}"

        # If the json_compilation_database_clang option is set, name the compilation database in accordance with
        # clang conventions
        if type == "json-compilation-database" and use_clang_naming
          file_name = "compile_commands.json"
        end

        output_path = output_file_name || File.join(File.expand_path(@output_directory), file_name)
        parts = ["cat '#{path}' | "]
        parts << "xcpretty"
        parts << "--report #{type}"
        parts << "--output '#{output_path}'"
        parts << "&> /dev/null "

        commands[output_path] = parts.join(" ")
      end

      return commands
    end
  end
end
