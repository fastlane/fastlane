require 'spaceship/client'

describe Match do
  describe Match::Portal::Cache do
    let(:default_params) do
      {
        platform: 'ios',
        type: 'development',
        additional_cert_types: nil,
        readonly: false,
        force: false,
        include_mac_in_profiles: true,

        force_for_new_devices: true,
        include_all_certificates: true,
        force_for_new_certificates: true
      }
    end

    let(:bundle_ids) { ['bundle_ID_1', 'bundle_ID_2'] }

    let(:default_sut) do
      Match::Portal::Cache.build(params: default_params, bundle_id_identifiers: bundle_ids)
    end

    describe "init" do
      it "builds correctly with params" do
        params = default_params
        bundle_ids = ['bundleID']

        cache = Match::Portal::Cache.build(params: params, bundle_id_identifiers: bundle_ids)

        expect(cache.bundle_id_identifiers).to eq(bundle_ids)
        expect(cache.platform).to eq(params[:platform])
        expect(cache.profile_type).to eq('IOS_APP_DEVELOPMENT')
        expect(cache.additional_cert_types).to eq(params[:additional_cert_types])
        expect(cache.needs_profiles_devices).to eq(true)
        expect(cache.needs_profiles_certificate_content).to eq(false)
        expect(cache.include_mac_in_profiles).to eq(params[:include_mac_in_profiles])
      end
    end

    describe "bundle_ids" do
      it 'caches bundle ids' do
        # GIVEN
        sut = default_sut

        allow(Match::Portal::Fetcher).to receive(:bundle_ids).with(bundle_id_identifiers: ['bundle_ID_1', 'bundle_ID_2']).and_return(['portal_bundle_id']).once

        # WHEN
        bundle_ids = sut.bundle_ids

        # THEN
        expect(bundle_ids).to eq(['portal_bundle_id'])

        # THEN used cached
        expect(sut.bundle_ids).to eq(['portal_bundle_id'])
      end
    end

    describe "devices" do
      it 'caches devices' do
        # GIVEN
        sut = default_sut

        allow(Match::Portal::Fetcher).to receive(:devices).with(include_mac_in_profiles: sut.include_mac_in_profiles, platform: sut.platform).and_return(['portal_device']).once

        # WHEN
        devices = sut.devices

        # THEN
        expect(devices).to eq(['portal_device'])
        # THEN used cached
        expect(sut.devices).to eq(['portal_device'])
      end
    end

    describe "devices" do
      it 'caches profiles' do
        # GIVEN
        sut = default_sut

        allow(Match::Portal::Fetcher).to receive(:profiles).with(needs_profiles_certificate_content: sut.needs_profiles_certificate_content, needs_profiles_devices: sut.needs_profiles_devices, profile_type: sut.profile_type).and_return(['portal_profile_1']).once

        # WHEN
        profiles = sut.profiles

        # THEN
        expect(profiles).to eq(['portal_profile_1'])
        # THEN used cached
        expect(sut.profiles).to eq(['portal_profile_1'])
      end

      it 'removes profile' do
        # GIVEN
        sut = default_sut

        allow(Match::Portal::Fetcher).to receive(:profiles).with(needs_profiles_certificate_content: sut.needs_profiles_certificate_content, needs_profiles_devices: sut.needs_profiles_devices, profile_type: sut.profile_type).and_return(['portal_profile_1', 'portal_profile_2']).once

        expect(sut.profiles).to eq(['portal_profile_1', 'portal_profile_2'])

        # WHEN
        sut.forget_portal_profile('portal_profile_1')

        # THEN
        expect(sut.profiles).to eq(['portal_profile_2'])
      end
    end

    describe "certificates" do
      it 'caches certificates' do
        # GIVEN
        sut = default_sut

        allow(Match::Portal::Fetcher).to receive(:certificates).with(additional_cert_types: sut.additional_cert_types, platform: sut.platform, profile_type: sut.profile_type).and_return(['portal_certificate_1']).once

        # WHEN
        certificates = sut.certificates

        # THEN
        expect(certificates).to eq(['portal_certificate_1'])
        # THEN used cached
        expect(sut.certificates).to eq(['portal_certificate_1'])
      end

      it 'resets certificates cache' do
        # GIVEN
        sut = default_sut

        allow(Match::Portal::Fetcher).to receive(:certificates).with(additional_cert_types: sut.additional_cert_types, platform: sut.platform, profile_type: sut.profile_type).and_return(['portal_certificate_1']).once

        certificates = sut.certificates
        expect(certificates).to eq(['portal_certificate_1'])

        allow(Match::Portal::Fetcher).to receive(:certificates).with(additional_cert_types: sut.additional_cert_types, platform: sut.platform, profile_type: sut.profile_type).and_return(['portal_certificate_2']).once

        # WHEN
        sut.reset_certificates

        # THEN
        expect(sut.certificates).to eq(['portal_certificate_2'])
        # THEN used cached
        expect(sut.certificates).to eq(['portal_certificate_2'])
      end
    end
  end
end
