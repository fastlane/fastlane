require_relative 'portal_fetcher'
require_relative 'module'

module Match
  class ProfileIncludes
    PROV_TYPES_WITH_DEVICES = [:adhoc, :development]
    PROV_TYPES_WITH_MULTIPLE_CERTIFICATES = [:development]

    def self.can_force_include?(params:, notify:)
      self.can_force_include_all_devices?(params: params, notify: notify) &&
        self.can_force_include_all_certificates?(params: params, notify: notify)
    end

    ###############
    #
    # DEVICES
    #
    ###############

    def self.should_force_include_all_devices?(params:, portal_profile:, cached_devices:)
      return false unless self.can_force_include_all_devices?(params: params)

      force = device_count_different?(portal_profile: portal_profile, platform: params[:platform], include_mac_in_profiles: params[:include_mac_in_profiles], cached_devices: cached_devices)

      return force
    end

    def self.can_force_include_all_devices?(params:, notify: false)
      return false if params[:readonly] || params[:force]
      return false unless params[:force_for_new_devices]

      provisioning_type = params[:type].to_sym

      can_force = PROV_TYPES_WITH_DEVICES.include?(provisioning_type)

      if !can_force && notify
        # App Store provisioning profiles don't contain device identifiers and
        # thus shouldn't be renewed if the device count has changed.
        UI.important("Warning: `force_for_new_devices` is set but is ignored for #{provisioning_type}.")
        UI.important("You can safely stop specifying `force_for_new_devices` when running Match for type '#{provisioning_type}'.")
      end

      can_force
    end

    def self.device_count_different?(portal_profile:, platform:, include_mac_in_profiles:, cached_devices:)
      return false unless portal_profile

      profile_device_count = portal_profile.devices.count

      devices = cached_devices
      devices ||= Match::Portal::Fetcher.devices(platform: platform, include_mac_in_profiles: include_mac_in_profiles)
      portal_device_count = devices.size

      device_count_different = portal_device_count != profile_device_count

      UI.important("Devices count differs. Portal count: #{portal_device_count}. Profile count: #{profile_device_count}") if device_count_different

      return device_count_different
    end

    ###############
    #
    # CERTIFICATES
    #
    ###############

    def self.should_force_include_all_certificates?(params:, portal_profile:, cached_certificates:)
      return false unless self.can_force_include_all_certificates?(params: params)

      force = certificate_count_different?(portal_profile: portal_profile, platform: params[:platform], cached_certificates: cached_certificates)

      return force
    end

    def self.can_force_include_all_certificates?(params:, notify: false)
      return false if params[:readonly] || params[:force]
      return false unless params[:force_for_new_certificates]

      unless params[:include_all_certificates]
        UI.important("You specified 'force_for_new_certificates: true', but new certificates will not be added, cause 'include_all_certificates' is 'false'") if notify
        return false
      end

      provisioning_type = params[:type].to_sym

      can_force = PROV_TYPES_WITH_MULTIPLE_CERTIFICATES.include?(provisioning_type)

      if !can_force && notify
        # All other (not development) provisioning profiles don't contain
        # multiple certificates, thus shouldn't be renewed
        # if the certificates  count has changed.
        UI.important("Warning: `force_for_new_certificates` is set but is ignored for non-'development' provisioning profiles.")
        UI.important("You can safely stop specifying `force_for_new_certificates` when running Match for '#{provisioning_type}' provisioning profiles.")
      end

      can_force
    end

    def self.certificate_count_different?(portal_profile:, platform:, cached_certificates:)
      return false unless portal_profile

      # When a certificate expires (not revoked) provisioning profile stays valid.
      # And if we regenerate certificate count will not differ:
      #   * For portal certificates, we filter out the expired one but includes a new certificate;
      #   * Profile still contains an expired certificate and is valid.
      # Thus, we need to check the validity of profile certificates too.
      profile_certs_count = portal_profile.certificates.select(&:valid?).count

      certificates = cached_certificates
      certificates ||= Match::Portal::Fetcher.certificates(platform: platform, profile_type: portal_profile.profile_type)
      portal_certs_count = certificates.size

      certificate_count_different = portal_certs_count != profile_certs_count

      UI.important("Certificate count differs. Portal count: #{portal_certs_count}. Profile count: #{profile_certs_count}") if certificate_count_different

      return certificate_count_different
    end
  end
end
