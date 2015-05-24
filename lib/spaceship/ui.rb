# require all the UI files
paths = Dir[File.expand_path "**/ui/*.rb", File.dirname(__FILE__)]
raise "Could not find UI classes to import" unless paths.count > 0
paths.each do |file|
  require file
end


module Spaceship
  class Client
    # Public getter for all UI related code
    def UI
      UserInterface.new(self)
    end

    class UserInterface
      def initialize(c)
        @client = c
      end

      def client
        @client
      end
    end
  end
end