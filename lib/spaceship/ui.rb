# require all the UI files
Dir[File.join(Dir.pwd, "**/ui/*.rb")].each do |file|
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