require 'logger'

module IosDeployKit
  module Helper

    def self.log
      if is_test?
        @@log ||= Logger.new(STDOUT).tap { |l| l.level = Logger::FATAL }
      else
        @@log ||= Logger.new(STDOUT)
      end

      @@log
    end

    def self.is_test?
      defined?SpecHelper
    end

    def self.xcode_path
      `xcode-select -p`.gsub("\n", '') + "/"
    end

    def self.transporter_path
      self.xcode_path + '../Applications/Application\ Loader.app/Contents/MacOS/itms/bin/iTMSTransporter'
    end
    
  end
end