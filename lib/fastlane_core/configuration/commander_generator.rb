require 'commander'

module FastlaneCore
  class CommanderGenerator
    include Commander::Methods

    # Calls the appropriate methods for commander to show the available parameters
    def generate(options)
      short_codes = []
      options.each do |option|
        appendix = (option.is_string ? "STRING" : "")
        type = (option.is_string ? String : nil)
        short_option = option.short_option || "-#{option.key.to_s[0]}"

        raise "Short option #{short_option} already taken for key #{option.key}".red if short_codes.include? short_option
        raise "-v is already used for the version (key #{option.key})".red if short_option == "-v"
        raise "-h is already used for the help screen (key #{option.key})".red if short_option == "-h"
        raise "-t is already used for the trace screen (key #{option.key})".red if short_option == "-t"

        short_codes << short_option

        # Example Call
        # c.option '-p', '--pattern STRING', String, 'Description'

        flag = "--#{option.key} #{appendix}"
        description = (option.description + " (#{option.env_name})")

        global_option short_option, flag, type, description
      end
    end
  end
end
