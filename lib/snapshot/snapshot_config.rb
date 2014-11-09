module Snapshot
  class SnapshotConfig
    
    # @return (SnapshotFile)
    attr_accessor :snapshot_file

    # @return (Array) List of simulators to use
    attr_accessor :devices

    # @return (Array) A list of languages which should be used
    attr_accessor :languages
    
    # @return (String) The iOS version (e.g. 8.1)
    attr_accessor :ios_version

    # @return (String) The path to the project/workspace
    attr_accessor :project_path



    # A shared singleton
    def self.shared_instance
      @@instance ||= SnapshotConfig.new
    end

    # @param path (String) the path to the config file to use (including the file name)
    def initialize(path = './Snapfile')
      set_defaults

      self.snapshot_file = SnapshotFile.new(path, self)
    end

    def set_defaults
      self.devices = [
        "iPhone 6",
        "iPhone 6 Plus",
        "iPhone 5",
        "iPhone 4S"
      ]

      self.languages = [
        'de-DE',
        'en-US'
      ]

      self.ios_version = '8.1'

      self.project_path = (Dir.glob("./*.xcworkspace").first rescue nil)
      self.project_path ||= (Dir.glob("./*.xcodeproj").first rescue nil)
    end
  end
end