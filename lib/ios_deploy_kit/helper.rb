require 'logger'

module IosDeployKit
  module Helper

    def self.log
      @@log ||= Logger.new(STDOUT)

      @@log
    end
    
  end
end