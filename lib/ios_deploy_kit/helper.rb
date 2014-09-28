require 'logger'

module IosDeployKit
  module Helper

    # Logging happens using this method
    def self.log
      if is_test?
        @@log ||= Logger.new(STDOUT).tap { |l| l.level = Logger::FATAL }
      else
        @@log ||= Logger.new(STDOUT)
      end

      @@log
    end

    # @return true if the currently running program is a unit test
    def self.is_test?
      defined?SpecHelper
    end

    # @return the full path to the Xcode developer tools of the currently
    #  running system
    def self.xcode_path
      `xcode-select -p`.gsub("\n", '') + "/"
    end

    # @return the full path to the iTMSTransporter executable
    def self.transporter_path
      self.xcode_path + '../Applications/Application\ Loader.app/Contents/MacOS/itms/bin/iTMSTransporter'
    end
    
  end
end