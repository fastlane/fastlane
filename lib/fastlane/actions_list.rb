module Fastlane
  class ActionsList
    def self.run
      all_actions = Fastlane::Actions.constants.select {|c| Class === Fastlane::Actions.const_get(c)}

      puts "Available Actions:".green
      all_actions.each do |action|
        name = action.to_s.gsub('Action', '').fastlane_uncapitalize
        puts "- " + name
      end
    end
  end
end