module Snapshot
  class LatestIosVersion
    def self.version
      return ENV["SNAPSHOT_IOS_VERSION"] if ENV["SNAPSHOT_IOS_VERSION"]

      output = `xcodebuild -version -sdk`.split("Mac").last # don't care about the Mac Part
      matched = output.match(/iPhoneSimulator([\d\.]+)\.sdk/)
      
      if matched.length > 1
        return matched[1]
      else
        raise "Could not determine installed iOS SDK version. Please pass it via the environment variable 'SNAPSHOT_IOS_VERSION'".red
      end
    end
  end
end