module Snapshot
  class SnapshotConfig
    
    # @return (String) The path to the used Deliverfile.
    attr_accessor :path

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
    def initialize(path = './Snapshotfile')
      raise "Config file not found at path '#{path}'".red unless File.exists?(path.to_s)

      self.path = path

      self.devices = [
        "iPhone 6 (8.1 Simulator)",
        "iPhone 6 Plus (8.1 Simulator)",
        "iPhone 5 (8.1 Simulator)",
        "iPhone 4S (8.1 Simulator)"
      ]

      self.languages = [
        'de-DE',
        'en-US'
      ]

      self.ios_version = '8.1'

      self.project_path = Dir.glob("./integration/Moto\ Deals/*.xcworkspace").first # TODO
    end
  end
end