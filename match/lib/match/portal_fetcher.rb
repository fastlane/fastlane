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

      # App Store Connect refuses a filter value longer than 5000 characters; fastlane#29783 saw failures below that.
      MAX_BUNDLE_ID_FILTER_LENGTH = 3500

      def self.bundle_ids(bundle_id_identifiers: nil, max_bundle_id_filter_length: MAX_BUNDLE_ID_FILTER_LENGTH)
        return Spaceship::ConnectAPI::BundleId.all(filter: nil) unless bundle_id_identifiers

        filters = bundle_id_identifiers.each_with_object([]) do |identifier, list|
          if list.empty? || list.last.length + 1 + identifier.length > max_bundle_id_filter_length
            list << identifier.dup
          else
            list.last << ",#{identifier}"
          end
        end
        filters.flat_map { |filter| Spaceship::ConnectAPI::BundleId.all(filter: { identifier: filter }) }
      end
    end
  end
end
