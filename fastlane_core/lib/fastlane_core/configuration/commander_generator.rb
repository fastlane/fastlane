require 'commander'

require_relative '../module'
require_relative '../ui/ui'

module FastlaneCore
  class CommanderGenerator
    include Commander::Methods

    # Calls the appropriate methods for commander to show the available parameters
    def generate(options, command: nil)
      # First, enable `always_trace`, to show the stack trace
      always_trace!

      used_switches = []
      options.each do |option|
        next if option.description.to_s.empty? # "private" options
        next unless option.display_in_shell

        short_switch = option.short_option
        key = option.key
        validate_short_switch(used_switches, short_switch, key)

        type = option.data_type

        # We added type: Hash to code generation, but Ruby's OptionParser doesn't like that
        # so we need to switch that to something that is supported, luckily, we have an `is_string`
        # property and if that is false, we'll default to nil
        if type == Hash
          type = option.is_string ? String : nil
        end

        # Boolean is a fastlane thing, it's either TrueClass, or FalseClass, but we won't know
        # that until runtime, so nil is the best we get
        if type == Fastlane::Boolean
          type = nil
        end

        # This is an important bit of trickery to solve the boolean option situation.
        #
        # Typically, boolean command line flags do not accept trailing values. If the flag
        # is present, the value is true, if it is missing, the value is false. fastlane
        # supports this style of flag. For example, you can specify a flag like `--clean`,
        # and the :clean option will be true.
        #
        # However, fastlane also supports another boolean flag style that accepts trailing
        # values much like options for Strings and other value types. That looks like
        # `--include_bitcode false` The problem is that this does not work out of the box
        # for Commander and OptionsParser. So, we need to get tricky.
        #
        # The value_appendix below acts as a placeholder in the switch definition that
        # states that we expect to have a trailing value for our options. When an option
        # declares a data type, we use the name of that data type in all caps like:
        # "--devices ARRAY". When the data type is nil, this implies that we're going
        # to be doing some special handling on that value. One special thing we do
        # automatically in Configuration is to coerce special Strings into boolean values.
        #
        # If the data type is nil, the trick we do is to specify a value placeholder, but
        # we wrap it in [] brackets to mark it as optional. That means that the trailing
        # value may or may not be present for this flag. If the flag is present, but the
        # value is not, we get a value of `true`. Perfect for the boolean flag base-case!
        # If the value is there, we'll actually get it back as a String, which we can
        # later coerce into a boolean.
        #
        # In this way we support handling boolean flags with or without trailing values.
        value_appendix = (type || '[VALUE]').to_s.upcase
        long_switch = "--#{option.key} #{value_appendix}"

        description = option.description
        description += " (#{option.env_name})" unless option.env_name.to_s.empty?

        # We compact this array here to remove the short_switch variable if it is nil.
        # Passing a nil value to global_option has been shown to create problems with
        # option parsing!
        #
        # See: https://github.com/fastlane/fastlane_core/pull/89
        #
        # If we don't have a data type for this option, we tell it to act like a String.
        # This allows us to get a reasonable value for boolean options that can be
        # automatically coerced or otherwise handled by the ConfigItem for others.
        args = [short_switch, long_switch, (type || String), description].compact

        if command
          command.option(*args)
        else
          # This is the call to Commander to set up the option we've been building.
          global_option(*args)
        end
      end
    end

    def validate_short_switch(used_switches, short_switch, key)
      return if short_switch.nil?

      UI.user_error!("Short option #{short_switch} already taken for key #{key}") if used_switches.include?(short_switch)
      UI.user_error!("-v is already used for the fastlane version (key #{key})") if short_switch == "-v"
      UI.user_error!("-h is already used for the fastlane help screen (key #{key})") if short_switch == "-h"
      UI.user_error!("-t is already used for the fastlane trace screen (key #{key})") if short_switch == "-t"

      used_switches << short_switch
    end
  end
end
