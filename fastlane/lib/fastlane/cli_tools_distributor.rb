module Fastlane
  # This class is responsible for checking the ARGV
  # to see if the user wants to launch another fastlane
  # tool or fastlane itself
  class CLIToolsDistributor
    class << self
      def take_off
        require "fastlane"

        # Array of symbols for the names of the available lanes
        # This doesn't actually use the Fastfile parser, but only
        # the available lanes. This way it's much faster, which
        # is very important in this case, since it will be executed
        # every time one of the tools is launched
        available_lanes = Fastlane::FastlaneFolder.available_lanes

        tool_name = ARGV.first ? ARGV.first.downcase : nil
        if tool_name && Fastlane::TOOLS.include?(tool_name.to_sym) && !available_lanes.include?(tool_name.to_sym)
          # Triggering a specific tool
          # This happens when the users uses things like
          #
          #   fastlane sigh
          #   fastlane snapshot
          #
          require tool_name
          begin
            # First, remove the tool's name from the arguments
            # Since it will be parsed by the `commander` at a later point
            # and it must not contain the binary name
            ARGV.shift

            # Import the CommandsGenerator class, which is used to parse
            # the user input
            require File.join(tool_name, "commands_generator")

            # Call the tool's CommandsGenerator class and let it do its thing
            Object.const_get(tool_name.fastlane_module)::CommandsGenerator.start
          rescue LoadError
            # This will only happen if the tool we call here, doesn't provide
            # a CommandsGenerator class yet
            # When we launch this feature, this should never be the case
            abort("#{tool_name} can't be called via `fastlane #{tool_name}`, run '#{tool_name}' directly instead".red)
          end
        else
          # Triggering fastlane to call a lane
          require "fastlane/commands_generator"
          Fastlane::CommandsGenerator.start
        end
      end
    end
  end
end
