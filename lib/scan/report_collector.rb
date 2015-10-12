module Scan
  class ReportCollector
    SUPPORTED = %w(html junit)

    def parse_raw_file(path)
      raise "Couldn't find file at path '#{path}'".red unless File.exist?(path)

      commands = generate_commands(path)
      commands.each do |command|
        system(command)
      end
    end

    def generate_commands(path)
      types = Scan.config[:output_types]
      types = types.split(",") if types.kind_of?(String) # might already be an array when passed via fastlane
      commands = []

      types.each do |raw|
        type = raw.strip

        unless SUPPORTED.include?(type)
          Helper.log.error "Couldn't find reporter '#{type}', available #{SUPPORTED.join(', ')}"
          next
        end

        file_name = "report.#{type}"
        output_path = File.join(Scan.config[:output_directory], file_name)
        parts = ["cat '#{path}' | "]
        parts << "xcpretty"
        parts << "--report #{type}"
        parts << "--output '#{output_path}'"

        commands << parts.join(" ")
      end
      return commands
    end
  end
end
