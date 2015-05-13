module Frameit
  # This class will parse the .string files
  class StringsParser
    def self.parse(path)
      raise "Couldn't find strings file at path '#{path}'".red unless File.exists?path
      raise "Must be .strings file, only got '#{path}'".red unless path.end_with?".strings"

      result = {}

      # A .strings file is UTF-16 encoded. We only want to deal with UTF-8
      content = `iconv -f UTF-16 -t UTF-8 '#{path}'`

      content.split("\n").each do |line|
        begin
          # We don't care about comments and empty lines
          if line.start_with?'"'
            key = line.match(/"(.*)" \= /)[1]
            value = line.match(/ \= "(.*)"/)[1]

            result[key] = value
          end
        rescue => ex
          Helper.log.error ex          
          Helper.log.error line
        end
      end
      
      result
    end
  end
end