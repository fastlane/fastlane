module Snapshot
  class CustomCallbackHandler
    def self.get
      Proc.new do |method_sym, arguments, block|
        binding.pry
        if method_sym == :setup_for_device_change or method_sym == :teardown_device
          
        end
      end
    end
  end
end