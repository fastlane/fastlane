require_relative '../model'
module Spaceship
  class ConnectAPI
    class BuildBundleFileSizes
      include Spaceship::ConnectAPI::Model

      attr_accessor :device_model
      attr_accessor :os_version
      attr_accessor :download_bytes
      attr_accessor :install_bytes

      attr_mapping({
        "deviceModel" => "device_model",
        "osVersion" => "os_version",
        "downloadBytes" => "download_bytes",
        "installBytes" => "install_bytes"
      })

      def self.type
        return "buildBundleFileSizes"
      end

      #
      # API
      #

      def self.all(client: nil, build_bundle_id: nil, limit: 30)
        client ||= Spaceship::ConnectAPI
        resps = client.get_build_bundles_build_bundle_file_sizes(build_bundle_id: build_bundle_id).all_pages
        resps.flat_map(&:to_models)
      end
    end
  end
end
