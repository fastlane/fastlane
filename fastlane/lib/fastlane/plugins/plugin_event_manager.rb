module Fastlane
  
  class HookAction
    attr_accessor :name
    attr_accessor :payload
    attr_accessor :prio
    def initialize(name, payload, prio)
      @name = name
      @payload = payload
      @prio = prio
    end
  end
  
  class HookFilter
    attr_accessor :name
    attr_accessor :default
    attr_accessor :prio
    def initialize(name, default)
      @name = name
      @default = default
    end
  end
  
  class EventManager
    attr_accessor :filters
    attr_accessor :action
    def self.all_actions
      @all_actions ||= []
    end
    
    def self.all_filters
      @all_filters ||= []
    end
    
    def self.add_action(name, prio, block)
      all_actions << 
    end
    
    def self.do_action(name, payload) 
      all_subscribers.each do |subscriber|
        if subscriber.respond_to? "action_handler"
          subscriber.action_handler(HookAction.new(name, payload))
        end
      end
    end
    
    def self.do_filter(name, default) 
      current_value = default
      all_subscribers.each do |subscriber|
        if subscriber.respond_to? "filter_handler"
          current_value = subscriber.filter_handler(HookFilter.new(name, current_value))
        end
      end
      current_value
    end
  end
end
