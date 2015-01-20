module Produce
  class Manager
    def self.start_producing
      DeveloperCenter.new.run
    end
  end
end