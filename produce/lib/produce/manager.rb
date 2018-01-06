require 'fastlane_core/print_table'
require_relative 'developer_center'
require_relative 'itunes_connect'

module Produce
  class Manager
    # Produces app at DeveloperCenter and ItunesConnect
    def self.start_producing
      FastlaneCore::PrintTable.print_values(config: Produce.config, hide_keys: [], title: "Summary for produce #{Fastlane::VERSION}")

      Produce::DeveloperCenter.new.run unless Produce.config[:skip_devcenter]
      return Produce::ItunesConnect.new.run unless Produce.config[:skip_itc]
    end
  end
end
