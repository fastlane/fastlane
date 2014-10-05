require 'ios_deploy_kit/deliverfile/dsl'

module IosDeployKit
  module Deliverfile
    # Deliverfile represents a Deliverfile created by a user of this library
    class Deliverfile

      include IosDeployKit::Deliverfile::Deliverfile::DSL

      # The path to the used Deliverfile.
      attr_accessor :path

      # Loads the Deliverfile from the given path
      # @param deliver_data (IosDeployKit::Deliverer) The deliverer which handles the
      #  results of running this deliverfile
      # @param (String) (optional) path to the file itself. This must also include the
      #  filename itself.
      def initialize(deliver_data, path = nil)
        path ||= './Deliverfile'
        raise "Deliverfile not found at path '#{path}'" unless File.exists?(path.to_s)

        self.path = path
        @deliver_data = deliver_data

        content = File.read(path)

        eval(content) # this is okay in this case

        @deliver_data.finished_executing_deliver_file
      end
    end
  end
end