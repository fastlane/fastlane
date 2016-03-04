module Scan
  class ReportCollector
    SUPPORTED = %w(html junit json-compilation-database)

    # Intialize with values from Scan.config matching these param names
    def initialize(open_report, output_types, output_directory)
      @open_report = open_report
      @output_types = output_types
      @output_directory = output_directory
    end

    def parse_raw_file(path)
      raise "Couldn't find file at path '#{path}'".red unless File.exist?(path)

      commands = generate_commands(path)
      commands.each do |output_path, command|
        system(command)
        Helper.log.info("Successfully generated report at '#{output_path}'".green)

        if @open_report and output_path.end_with?(".html")
          # Open the HTML file
          `open --hide '#{output_path}'`
        end
      end
    end

    # Returns a hash containg the resulting path as key and the command as value
    def generate_commands(path, types: nil, output_file_name: nil)
      types ||= @output_types
      types = types.split(",") if types.kind_of?(String) # might already be an array when passed via fastlane
      commands = {}

      types.each do |raw|
        type = raw.strip

        unless SUPPORTED.include?(type)
          Helper.log.error "Couldn't find reporter '#{type}', available #{SUPPORTED.join(', ')}"
          next
        end

        file_name = "report.#{type}"
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
