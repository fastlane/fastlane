module Snapshot
  class SnapshotConfig
    
    # @return (String) The path to the used Deliverfile.
    attr_accessor :path

    # @return (Array) List of simulators to use
    attr_accessor :device_types

    # @return ()
    attr_accessor :languages
    attr_accessor :ios_version

    # @param path (String) the path to the config file to use (including the file name)
    def initialize(path)
      raise "Config file not found at path '#{path}'".red unless File.exists?(path.to_s)

      self.path = path
      

      content = File.read(path)
    end
  end
end