require 'commander'

module FastlaneCore
  class CommanderGenerator
    include Commander::Methods

    def generate(options)
      short_codes = []
      options.each do |option|
        appendix = (option.is_string ? "STRING" : "")
        type = (option.is_string ? String : nil)
        short_option = option.short_option || "-#{option.key.to_s[0]}"

        raise "Short option #{short_option} already taken for key #{option.key}".red if short_codes.include?short_option
        raise "-v is already used for the version (key #{option.key})".red if short_option == "-v"
        raise "-h is already used for the help screen (key #{option.key})".red if short_option == "-h"
        
        short_codes << short_option
        global_option short_option, "--#{option.key} #{appendix}", type, (option.description + " (#{option.env_name})")
      end
    end
  end
end