module Snapshot
  class LatestIosVersion
    @@version = nil
    def self.version
      return ENV["SNAPSHOT_IOS_VERSION"] if ENV["SNAPSHOT_IOS_VERSION"]
      return @@version if @@version

      output = `xcodebuild -version -sdk`.split("Mac").last # don't care about the Mac Part
      matched = output.match(/iPhoneSimulator([\d\.]+)\.sdk/)
      
      if matched.length > 1
        return @@version ||= matched[1]
      else
        raise "Could not determine installed iOS SDK version. Please pass it via the environment variable 'SNAPSHOT_IOS_VERSION'".red
      end
    end
  end
end