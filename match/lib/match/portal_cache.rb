require 'fastlane_core/provisioning_profile'
require 'spaceship/client'
require_relative 'portal_fetcher'
module Match
  class Portal
    class Cache
      def self.build(params:, bundle_id_identifiers:)
        require_relative 'profile_includes'
        require 'sigh'

        profile_type = Sigh.profile_type_for_distribution_type(
          platform: params[:platform],
          distribution_type: params[:type]
        )

        cache = Portal::Cache.new(
          platform: params[:platform],
          profile_type: profile_type,
          additional_cert_types: params[:additional_cert_types],
          bundle_id_identifiers: bundle_id_identifiers,
          needs_profiles_devices: ProfileIncludes.can_force_include_all_devices?(params: params, notify: true),
          needs_profiles_certificate_content: !ProfileIncludes.can_force_include_all_certificates?(params: params, notify: true),
          include_mac_in_profiles: params[:include_mac_in_profiles]
        )

        return cache
      end

      attr_reader :platform, :profile_type, :bundle_id_identifiers, :additional_cert_types, :needs_profiles_devices, :needs_profiles_certificate_content, :include_mac_in_profiles

      def initialize(platform:, profile_type:, additional_cert_types:, bundle_id_identifiers:, needs_profiles_devices:, needs_profiles_certificate_content:, include_mac_in_profiles:)
        @platform = platform
        @profile_type = profile_type

        # Bundle Ids
        @bundle_id_identifiers = bundle_id_identifiers

        # Certs
        @additional_cert_types = additional_cert_types

        # Profiles
        @needs_profiles_devices = needs_profiles_devices
        @needs_profiles_certificate_content = needs_profiles_certificate_content

        # Devices
        @include_mac_in_profiles = include_mac_in_profiles
      end

      def portal_profile(stored_profile_path:, keychain_path:)
        parsed = FastlaneCore::ProvisioningProfile.parse(stored_profile_path, keychain_path)
        uuid = parsed["UUID"]

        portal_profile = self.profiles.detect { |i| i.uuid == uuid }

        portal_profile
      end

      def reset_certificates
        @certificates = nil
      end

      def forget_portal_profile(portal_profile)
        return unless @profiles && portal_profile

        @profiles -= [portal_profile]
      end

      def bundle_ids
        @bundle_ids ||= Match::Portal::Fetcher.bundle_ids(
          bundle_id_identifiers: @bundle_id_identifiers
        )

        return @bundle_ids.dup
      end

      def certificates
        @certificates ||= Match::Portal::Fetcher.certificates(
          platform: @platform,
          profile_type: @profile_type,
          additional_cert_types: @additional_cert_types
        )

        return @certificates.dup
      end

      def profiles
        @profiles ||= Match::Portal::Fetcher.profiles(
          profile_type: @profile_type,
          needs_profiles_devices: @needs_profiles_devices,
          needs_profiles_certificate_content: @needs_profiles_certificate_content
        )

        return @profiles.dup
      end

      def devices
        @devices ||= Match::Portal::Fetcher.devices(
          platform: @platform,
          include_mac_in_profiles: @include_mac_in_profiles
        )

        return @devices.dup
      end
    end
  end
end
