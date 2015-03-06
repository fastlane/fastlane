require 'commander'

module FastlaneCore
  class CommanderGenerator
    include Commander::Methods

    def generate(options)
      options.each do |option|
        appendix = (option.is_string ? "STRING" : "")
        type = (option.is_string ? String : nil)
        short_option = option.short_option || "-#{option.key.to_s[0]}"
        global_option short_option, "--#{option.key} #{appendix}", type, (option.description + " (#{option.env_name})")
      end
    end
  end
end