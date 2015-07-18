module Produce
  class Manager
    # Produces app at DeveloperCenter and ItunesConnect
    def self.start_producing
      Produce::DeveloperCenter.new.run unless Produce.config[:skip_devcenter]
      return Produce::ItunesConnect.new.run unless Produce.config[:skip_itc]
    end
  end
end
