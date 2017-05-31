require 'plist'
require 'review/runner'

module Review
  class Manager
    def self.start
      Review::Runner.new.run
    end
  end
end
