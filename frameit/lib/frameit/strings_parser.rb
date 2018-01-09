require_relative 'module'

module Frameit
  # This class will parse the .string files
  class StringsParser
    def self.parse(path)
      UI.user_error!("Couldn't find strings file at path '#{path}'") unless File.exist?(path)
      UI.user_error!("Must be .strings file, only got '#{path}'") unless path.end_with?(".strings")

      result = {}

      # A .strings file is UTF-16 encoded. We only want to deal with UTF-8
      content = `iconv -f UTF-16 -t UTF-8 '#{path}' 2>&1`

      content.split("\n").each_with_index do |line, index|
        begin
          # We don't care about comments and empty lines
          if line.start_with?('"')
            key = line.match(/"(.*)" \= /)[1]
            value = line.match(/ \= "(.*)"/)[1]

            result[key] = value
          end
        rescue => ex
          UI.error("Error parsing #{path} line #{index + 1}: '#{line}'")
          UI.verbose("#{ex.message}\n#{ex.backtrace.join('\n')}")
        end
      end

      if result.empty?
        UI.error("Empty parsing result for #{path}. Please make sure the file is valid and UTF16 Big-endian encoded")
      end

      result
    end
  end
end
