module Produce
  class Manager
    def self.start_producing
      DeveloperCenter.new.run
      return ItunesConnect.new.run unless Config.val(:skip_itc)
    end
  end
end
