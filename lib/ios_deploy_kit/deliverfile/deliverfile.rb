require 'ios_deploy_kit/deliverfile/dsl'

module IosDeployKit
  module Deliverfile
    class DeliverfileError < StandardError
    end

    class Deliverfile

      include IosDeployKit::Deliverfile::Deliverfile::DSL

      attr_accessor :path

      # Loads the Deliverfile from the given path
      # @param (String) path to the file itself. This must also include the
      #  filename itself
      def initialize(path = './Deliverfile')
        raise "Deliverfile not found at path '#{path}'" unless File.exists?(path)

        self.path = path

        content = File.read(path)

        eval(content) # this is okay in this case
      end
    end
  end
end