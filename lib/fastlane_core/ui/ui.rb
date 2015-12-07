module FastlaneCore
  class UI
    class << self
      def current
        @current ||= Terminal.new
      end
    end

    def self.method_missing(method_sym, *args, &_block)
      raise "Only pass exactly one parameter to UI".red if args.length != 1

      # not using `responds` beacuse we don't care about methods like .to_s and so on
      interface_methods = Interface.instance_methods - Object.instance_methods
      raise "Unknown method '#{method_sym}', supported #{interface_methods}" unless interface_methods.include?(method_sym)

      self.current.send(method_sym, args.first)
    end
  end
end

require 'fastlane_core/ui/interface'

# Import all available implementations
Dir[File.expand_path('implementations/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end

require 'fastlane_core/ui/disable_colors' if ENV["FASTLANE_DISABLE_COLORS"]
