module Fastlane
  class EventAction
    attr_accessor :name
    attr_accessor :block
    attr_accessor :prio
    def initialize(name, prio, &block)
      @name = name
      @prio = prio
      @block = block
    end
  end

  class EventFilter
    attr_accessor :name
    attr_accessor :prio
    attr_accessor :block
    def initialize(name, prio, &block)
      @name = name
      @prio = prio
      @block = block
    end
  end

  class Events
    attr_accessor :filters
    attr_accessor :action
    def self.all_actions
      @all_actions ||= []
      @all_actions = @all_actions.sort_by(&:prio)
    end

    def self.all_filters
      @all_filters ||= []
      @all_filters = @all_filters.sort_by(&:prio)
    end

    def self.add_action(name, prio, &block)
      all_actions << EventAction.new(name, prio, &block)
    end

    def self.add_filter(name, prio, &block)
      all_filters << EventFilter.new(name, prio, &block)
    end

    def self.do_action(name, payload)
      all_actions.each do |action|
        next unless action.name == name
        action.block.call(name, payload)
      end
    end

    def self.do_filter(name, default)
      current_value = default
      all_filters.each do |filter|
        next unless filter.name == name
        current_value = filter.block.call(name, current_value)
      end
      current_value
    end
  end
end
