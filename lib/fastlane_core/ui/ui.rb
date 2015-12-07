module FastlaneCore
  class UI
    class << self
      def current
        @current ||= Terminal.new
      end
    end

    def self.method_missing(method_sym, *args, &block)
      raise "Only pass exactly one parameter to UI".red if args.length != 1

      # not using `responds` beacuse we don't care about methods like .to_s and so on
      interface_methods = Interface.instance_methods - Object.instance_methods
      raise "Unknown method '#{method_sym}', supported #{interface_methods}" unless interface_methods.include?(method_sym)

      self.current.send(method_sym, args.first)
    end
  end
end

require 'fastlane_core/ui/interface'
require 'fastlane_core/ui/terminal'
