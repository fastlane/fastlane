require 'deliver/deliverfile/dsl'

module Deliver
  module Deliverfile
    # Deliverfile represents a Deliverfile created by a user of this library
    class Deliverfile

      FILE_NAME = "Deliverfile"

      include Deliver::Deliverfile::Deliverfile::DSL

      # The path to the used Deliverfile.
      attr_accessor :path

      # Loads the Deliverfile from the given path
      # @param deliver_data (Deliver::Deliverer) The deliverer which handles the
      #  results of running this deliverfile
      # @param (String) path (optional) to the file itself. This must also include the
      #  filename itself.
      def initialize(deliver_data, path = nil)
        path ||= "./#{FILE_NAME}"
        raise "#{FILE_NAME} not found at path '#{File.expand_path(path)}'".red unless File.exists?(path.to_s)

        self.path = path
        @deliver_data = deliver_data

        content = File.read(path)

        eval(content) # this is okay in this case

        @deliver_data.finished_executing_deliver_file
      end
    end
  end
end
