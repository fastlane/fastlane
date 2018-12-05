module FastlaneCore
  class UI
    class << self
      attr_accessor(:ui_object)

      def ui_object
        require_relative 'implementations/shell'
        @ui_object ||= Shell.new
      end

      def method_missing(method_sym, *args, &_block)
        # not using `responds` because we don't care about methods like .to_s and so on
        require_relative 'interface'
        interface_methods = FastlaneCore::Interface.instance_methods - Object.instance_methods
        UI.user_error!("Unknown method '#{method_sym}', supported #{interface_methods}") unless interface_methods.include?(method_sym)

        self.ui_object.send(method_sym, *args)
      end
    end
  end
end

# Import all available implementations
Dir[File.dirname(__FILE__) + '/implementations/*.rb'].each do |file|
  require_relative file
end
