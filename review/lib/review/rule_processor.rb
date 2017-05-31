require 'spaceship'

module Review
  class DataPointToCheck
    attr_accessor :text
    attr_accessor :property_name
    attr_accessor :friendly_name

    def initialize(text, property_name, friendly_name)
      @text = text
      @property_name = property_name
      @friendly_name = friendly_name
    end
  end

  class RuleProcessor
    def self.process_app_version(app_version: nil)
      attribute_keys = app_version.class.annotations.keys
      data = attribute_keys.map do |attribute_name|
        text = app_version.public_send(attribute_name)
        friendly_name = app_version.class.annotations(attribute_name)[:keeper_rule_data][:friendly_name]
        property_name = attribute_name
        DataPointToCheck.new(text, property_name, friendly_name)
      end

      # this is just proof of concept
      self.rules.each do |rule|
        data.each do |data_point|
          rule[data_point]
        end
      end
    end

    def self.rules
      return [->(data_point) { puts data_point.text }]
    end
  end
end
