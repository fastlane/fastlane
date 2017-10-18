module FastlaneCore
  class UI
    class << self
      def current
        @current ||= Shell.new
      end
    end

    def self.method_missing(method_sym, *args, &_block)
      # not using `responds` because we don't care about methods like .to_s and so on
      interface_methods = Interface.instance_methods - Object.instance_methods
      UI.user_error!("Unknown method '#{method_sym}', supported #{interface_methods}") unless interface_methods.include?(method_sym)

      self.current.send(method_sym, *args)
    end
  end
end

require 'fastlane_core/ui/interface'

# Import all available implementations
Dir[File.expand_path('implementations/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end
