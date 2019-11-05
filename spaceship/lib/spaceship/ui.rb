paths = Dir[File.expand_path("**/ui/*.rb", File.dirname(__FILE__))]
raise "Could not find UI classes to import" unless paths.count > 0
paths.each do |file|
  require file
end

module Spaceship
  class Client
    # All User Interface related code lives in this class
    class UserInterface
      # Access the client this UserInterface object is for
      attr_reader :client

      # Is called by the client to generate one instance of UserInterface
      def initialize(c)
        @client = c
      end
    end

    # Public getter for all UI related code
    # rubocop:disable Style/MethodName
    def UI
      UserInterface.new(self)
    end
    # rubocop:enable Style/MethodName
  end
end
