require 'ios_deploy_kit/deliverfile/dsl'

module IosDeployKit
  class DeliverfileError < StandardError 
  end
  
  class Deliverfile

    include IosDeployKit::Deliverfile::DSL

    attr_accessor :path

    def initialize(path = './')
      full_path = path + "Deliverfile"
      raise "not here" unless File.exists?(path) # TODO: Error handling
      self.path = full_path

      content = File.read(full_path)
      
      eval(content)
    end
  end
end