require 'logger'

module IosDeployKit
  module Helper

    def self.log
      @@log ||= Logger.new(STDOUT)

      @@log
    end

    def self.xcode_path
      `xcode-select -p`.gsub("\n", '') + "/"
    end

    def self.transporter_path
      self.xcode_path + '../Applications/Application\ Loader.app/Contents/MacOS/itms/bin/iTMSTransporter'
    end
    
  end
end