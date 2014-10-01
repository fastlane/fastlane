require 'ios_deploy_kit/deliverfile/dsl'

module IosDeployKit
  module Deliverfile
    class Deliverfile

      include IosDeployKit::Deliverfile::Deliverfile::DSL

      attr_accessor :path

      # Loads the Deliverfile from the given path
      # @param # TODO
      # @param (String) (optional) path to the file itself. This must also include the
      #  filename itself
      def initialize(delegate, path = nil)
        path ||= './Deliverfile'
        raise "Deliverfile not found at path '#{path}'" unless File.exists?(path.to_s)

        self.path = path
        @deliver_data = delegate

        content = File.read(path)

        eval(content) # this is okay in this case

        @deliver_data.finished_executing_deliver_file
      end
    end
  end
end