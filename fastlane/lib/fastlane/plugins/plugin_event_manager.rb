module Fastlane
  class PluginEvent
    attr_accessor :category
    attr_accessor :payload
    def initialize(category, payload)
      @category = category
      @payload = payload
    end
  end
  class PluginEventManager
    attr_accessor :all_subscribers
    def self.all_subscribers
      @all_subscribers ||= []
    end

    def self.subscribe(listener)
      all_subscribers << listener
    end

    def self.publish(event)
      all_subscribers.each do |subscriber|
        if subscriber.respond_to? "event_receiver"
          subscriber.event_receiver(event)
        end
      end
    end
  end
end
