module Fastlane
  module ActionSets
    module Amazon

      def do_something
        puts "do something"
      end

    end
  end
end

module Fastlane::ActionSets::Amazon
  class Client
    def initialize
    end

    def do_stuff
      puts "do stuff"
    end
  end
end