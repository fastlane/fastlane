require "fastlane_core"
require 'terminal-table'

module Pilot
  class GroupManager < Manager
    def create_group(options)
      start(options)
      if config[:apple_id].to_s.length == 0 and config[:app_identifier].to_s.length == 0
        config[:app_identifier] = UI.input("App Identifier: ")
        config[:apple_id] = Spaceship::Tunes::Application.find(config[:app_identifier]).apple_id
      end
      if config[:apple_id].to_s.length == 0 and config[:app_identifier].to_s.length != 0
        config[:apple_id] = Spaceship::Tunes::Application.find(config[:app_identifier]).apple_id
      end
      if config[:group_name].to_s.length == 0
        config[:group_name] = UI.input("Group Name: ")
      end
      Spaceship::TestFlight::Group.create_group!(app_id: config[:apple_id], group_name: config[:group_name])
      UI.success "Successfully added #{config[:group_name]} to app"
    end
  end
end
