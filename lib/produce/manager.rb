module Produce
  class Manager
    def self.start_producing
      DeveloperCenter.new.run
      ItunesConnect.new.run
    end
  end
end