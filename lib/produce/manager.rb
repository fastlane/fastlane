module Produce
  class Manager
    def self.start_producing
      DeveloperCenter.new.run
      return ItunesConnect.new.run unless (ENV["PRODUCE_SKIP_ITC"].to_s.length > 0)
    end
  end
end
