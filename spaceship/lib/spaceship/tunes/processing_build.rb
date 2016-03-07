module Spaceship
  module Tunes
    # Represents a build which doesn't have a version number yet and is either processing or is stuck
    class ProcessingBuild < Build
      # @return [String] The state of this build
      # @example
      #   ITC.apps.betaProcessingStatus.InvalidBinary
      # @example
      #   ITC.apps.betaProcessingStatus.Created
      # @example
      #   ITC.apps.betaProcessingStatus.Uploaded
      attr_accessor :state

      # @return (Integer) The number of ticks since 1970 (e.g. 1413966436000)
      attr_accessor :upload_date

      attr_mapping(
        'processingState' => :state,
        'uploadDate' => :upload_date
      )

      class << self
        def factory(attrs)
          self.new(attrs)
        end
      end
    end
  end
end
