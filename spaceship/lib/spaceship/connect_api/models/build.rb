module Spaceship
  module ConnectAPI
    class Build
      include Spaceship::ConnectAPI::Model

      attr_accessor :version
      attr_accessor :min_os_version
      attr_accessor :processing_state

      attr_accessor :pre_release_version
      attr_accessor :app

      attr_mapping({
        "version" => "version",
        "minOsVersion" => "min_os_version",
        "processingState" => "processing_state",
        
        "preReleaseVersion" => "pre_release_version",
        "app" => "app"
      })

      def self.type
        return "builds"
      end
    end
  end
end
