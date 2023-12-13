require 'spaceship/client'

describe Match do
  describe Match::Portal::Fetcher do
    let(:default_sut) { Match::Portal::Fetcher }

    let(:portal_bundle_id) { double("portal_bundle_id") }
    let(:portal_device) { double("portal_device") }
    let(:portal_certificate) { double("portal_certificate") }

    let(:portal_profile) { double("portal_profile") }
    let(:portal_profile_udid) { double("portal_profile_udid") }

    let(:deviceClass) { Spaceship::ConnectAPI::Device::DeviceClass }
    let(:deviceStatus) { Spaceship::ConnectAPI::Device::Status }
    let(:certificateType) { Spaceship::ConnectAPI::Certificate::CertificateType }
    let(:profileState) { Spaceship::ConnectAPI::Profile::ProfileState }

    let(:default_device_all_params) do
      {
        filter: { platform: 'IOS,UNIVERSAL', status: 'ENABLED' },
        client: anything
      }
    end

    let(:default_certificates_all_params) do
      {
        filter: { certificateType: anything }
      }
    end

    let(:default_profile_all_params) do
      {
        filter: { profileType: anything },
        includes: 'bundleId,devices,certificates'
      }
    end

    let(:default_bundle_id_all_params) do
      {
        filter: { identifier: anything }
      }
    end

    before do
      allow(portal_device).to receive(:device_class).and_return(deviceClass::IPHONE)
      allow(portal_device).to receive(:enabled?).and_return(true)

      allow(portal_certificate).to receive(:valid?).and_return(true)

      allow(portal_profile).to receive(:uuid).and_return(portal_profile_udid)
      allow(portal_profile).to receive(:profile_state).and_return(profileState::ACTIVE)
      allow(portal_profile).to receive(:devices).and_return([portal_device])
      allow(portal_profile).to receive(:certificates).and_return([portal_certificate])
    end

    before do
      allow(Spaceship::ConnectAPI::Device).to receive(:all).with(default_device_all_params).and_return([portal_device])
      allow(Spaceship::ConnectAPI::Certificate).to receive(:all).with(default_certificates_all_params).and_return([portal_certificate])
      allow(Spaceship::ConnectAPI::Profile).to receive(:all).with(default_profile_all_params).and_return([portal_profile])
      allow(Spaceship::ConnectAPI::BundleId).to receive(:all).with(default_bundle_id_all_params).and_return([portal_bundle_id])
    end

    describe "certificates" do
      it "fetches certificates" do
        # GIVEN
        sut = default_sut

        # WHEN
        portal_certificates = sut.certificates(platform: 'ios', profile_type: 'development', additional_cert_types: nil)

        # THEN
        expect(portal_certificates).to eq([portal_certificate])
      end
    end

    describe "devices" do
      it "fetches devices" do
        # GIVEN
        sut = default_sut

        # WHEN
        portal_devices = sut.devices(platform: 'ios')

        # THEN
        expect(portal_devices).to eq([portal_device])
      end
    end

    describe "bundle ids" do
      it "fetches bundle ids" do
        # GIVEN
        sut = default_sut

        # WHEN
        portal_bundle_ids = sut.bundle_ids(bundle_id_identifiers: ['bundle_id'])

        # THEN
        expect(portal_bundle_ids).to eq([portal_bundle_id])
      end
    end

    describe "profiles" do
      it "fetches profiles" do
        # GIVEN
        sut = default_sut

        # WHEN
        portal_profiles = sut.profiles(profile_type: 'profile_type', needs_profiles_devices: true, needs_profiles_certificate_content: false, name: nil)

        # THEN
        expect(portal_profiles).to eq([portal_profile])
      end

      it "fetches profiles with name" do
        # GIVEN
        sut = default_sut

        profile_params = default_profile_all_params
        profile_name = 'profile name'
        profile_params[:filter][:name] = profile_name

        allow(Spaceship::ConnectAPI::Profile).to receive(:all).with(profile_params).and_return([portal_profile])

        # WHEN
        portal_profiles = sut.profiles(profile_type: 'profile_type', needs_profiles_devices: true, needs_profiles_certificate_content: false, name: profile_name)

        # THEN
        expect(portal_profiles).to eq([portal_profile])
      end
    end
  end
end
