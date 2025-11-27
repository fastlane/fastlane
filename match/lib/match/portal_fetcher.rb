require 'fastlane_core/provisioning_profile'
require 'spaceship/client'
require 'spaceship/connect_api/models/profile'

module Match
  class Portal
    module Fetcher
      def self.profiles(profile_type:, needs_profiles_devices: false, needs_profiles_certificate_content: false, name: nil)
        includes = ['bundleId']

        if needs_profiles_devices
          includes += ['devices', 'certificates']
        end

        if needs_profiles_certificate_content
          includes += ['certificates']
        end

        profiles = Spaceship::ConnectAPI::Profile.all(
          filter: { profileType: profile_type, name: name }.compact,
          includes: includes.uniq.join(',')
        )

        profiles
      end

      def self.certificates(platform:, profile_type:, additional_cert_types:)
        require 'sigh'
        certificate_types = Sigh.certificate_types_for_profile_and_platform(platform: platform, profile_type: profile_type)

        additional_cert_types ||= []
        additional_cert_types.map! do |cert_type|
          case Match.cert_type_sym(cert_type)
          when :mac_installer_distribution
            Spaceship::ConnectAPI::Certificate::CertificateType::MAC_INSTALLER_DISTRIBUTION
          when :developer_id_installer
            Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPER_ID_INSTALLER
          end
        end

        certificate_types += additional_cert_types

        filter = { certificateType: certificate_types.uniq.sort.join(',') } unless certificate_types.empty?

        certificates = Spaceship::ConnectAPI::Certificate.all(
          filter: filter
        ).select(&:valid?)

        certificates
      end

      def self.devices(platform: nil, include_mac_in_profiles: false)
        devices = Spaceship::ConnectAPI::Device.devices_for_platform(
          platform: platform,
          include_mac_in_profiles: include_mac_in_profiles
        )

        devices
      end

      # 4096 is the max URL length in the App Store Connect API request.
      # If the URL length is too long, the ASC API will return a 500 HTTP response code.
      #
      # The MAX_BUNDLE_ID_FILTER_LENGTH constant is calculated as follows:
      #   - minus 84 is the length of the https://.../bundleIds?limit=200&filter%25Bidentifier%25D= in the URL.
      #   - minus 12 to round up to the round number of 4000.
      #   - minus 100 to leave some space for the possible other parameters in the URL and URL changes.
      MAX_BUNDLE_ID_FILTER_LENGTH = 3900

      def self.bundle_ids(bundle_id_identifiers: nil, max_bundle_id_filter_length: MAX_BUNDLE_ID_FILTER_LENGTH)
        # Bundle IDs to fetch.
        bundle_id_identifiers ||= []

        # Radar: FB21179960: v1/bundleIds?filter returns 500 HTTP status code if the URL is longer than 4096 bytes.
        #
        # To avoid the 500 HTTP response code, we need to fetch bundle IDs in multiple requests by splitting the bundle ID identifiers into multiple filters.
        # The splitting logic is if the current filter length is more than 3900 characters, reset the current filter and start a new one.

        # Splitted bundle IDs array into multiple filters we will fetch separately.
        identifiers_filters = [[]]
        current_filter_length = 0
        current_filter_count = 0
        current_identifiers_filter = identifiers_filters.last # The current bundle IDs identifiers filter.
        (0..bundle_id_identifiers.count - 1).each do |index|
          bundle_id_identifier = bundle_id_identifiers[index]

          if current_filter_length + bundle_id_identifier.length > max_bundle_id_filter_length
            # if next length will be greater than the max bundle id filter length, reset the current filter and start a new one.
            current_identifiers_filter = []
            identifiers_filters.push(current_identifiers_filter)
            current_filter_length = 0
            current_filter_count = 0
          end

          current_identifiers_filter.push(bundle_id_identifier)
          # Update the filter length and count for the current filter.
          current_filter_length += bundle_id_identifier.length + 3 # ',' is encoded as '%2C' in the URL
          current_filter_count += 1
        end

        # All fetched bundle IDs.
        bundle_ids = []

        # Fetch bundle IDs separately for each splitted chunk.
        identifiers_filters.each do |identifiers_filter|
          filter = { identifier: identifiers_filter.join(',') } unless identifiers_filter.empty?

          bundle_ids += Spaceship::ConnectAPI::BundleId.all(
            filter: filter
          )

        end

        bundle_ids
      end
    end
  end
end
