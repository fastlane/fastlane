module Fastlane
  class FastlaneConfig
    #
    # Limited to actions that take a single argument, not params
    #
    SUPPORTED_ACTIONS = %w(
      min_fastlane_version
      default_platform
      team_id
    )

    def method_missing(method_sym, *args, &block)
      method_str = method_sym.to_s
      return super unless method_str =~ /\=$/

      root = method_str.chomp("=")
      return super unless SUPPORTED_ACTIONS.include?(root)

      # It was a setter. Should have a single argument.
      raise ArgumentError, "#{method_sym} requires one argument." unless args.count == 1

      action_class = Actions.const_get("#{root.split("_").map(&:capitalize).join}Action")
      return super unless action_class

      action_class.run([args.first])
    end
  end
end
