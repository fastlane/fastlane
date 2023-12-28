describe Match do
  describe Match::ProfileIncludes do
    describe "counts" do
      let(:portal_profile) { double("profile") }
      let(:profile_device) { double("profile_device") }
      let(:profile_certificate) { double("profile_certificate") }

      before do
        allow(portal_profile).to receive(:devices).and_return([profile_device])
        allow(portal_profile).to receive(:certificates).and_return([profile_certificate])
        allow(profile_device).to receive(:id).and_return(1)
        allow(profile_certificate).to receive(:id).and_return(1)
      end

      describe "#devices_differ?" do
        it "returns false if devices are the same" do
          # WHEN
          devices_differ = Match::ProfileIncludes.devices_differ?(portal_profile: portal_profile, platform: 'ios', include_mac_in_profiles: true, cached_devices: [profile_device])

          # THEN
          expect(devices_differ).to be(false)
        end

        it "returns true if devices differ even when the count is the same" do
          # GIVEN
          portal_device = double("profile_device")
          allow(portal_device).to receive(:id).and_return(2)

          # WHEN
          devices_differ = Match::ProfileIncludes.devices_differ?(portal_profile: portal_profile, platform: 'ios', include_mac_in_profiles: true, cached_devices: [portal_device])

          # THEN
          expect(devices_differ).to be(true)
        end

        it "returns true if devices differ" do
          # GIVEN
          portal_device = double("profile_device")
          allow(portal_device).to receive(:id).and_return(2)

          # WHEN
          devices_differ = Match::ProfileIncludes.devices_differ?(portal_profile: portal_profile, platform: 'ios', include_mac_in_profiles: true, cached_devices: [portal_device, profile_device])

          # THEN
          expect(devices_differ).to be(true)
        end
      end

      describe "#certificates_differ?" do
        it "returns false if certificates are the same" do
          # WHEN
          certificates_differ = Match::ProfileIncludes.certificates_differ?(portal_profile: portal_profile, platform: 'ios', cached_certificates: [profile_certificate])

          # THEN
          expect(certificates_differ).to be(false)
        end

        it "returns true if certs differ even when the count is the same" do
          # GIVEN
          portal_cert = double("profile_device")
          allow(portal_cert).to receive(:id).and_return(2)

          # WHEN
          certificates_differ = Match::ProfileIncludes.certificates_differ?(portal_profile: portal_profile, platform: 'ios', cached_certificates: [portal_cert])

          # THEN
          expect(certificates_differ).to be(true)
        end

        it "returns true if certs differ" do
          # GIVEN
          portal_cert = double("profile_device")
          allow(portal_cert).to receive(:id).and_return(2)

          # WHEN
          certificates_differ = Match::ProfileIncludes.certificates_differ?(portal_profile: portal_profile, platform: 'ios', cached_certificates: [profile_certificate, portal_cert])

          # THEN
          expect(certificates_differ).to be(true)
        end
      end
    end

    describe "can's" do
      let(:params) { double("params") }

      before do
        allow(params).to receive(:[]).with(:type).and_return('development')

        allow(params).to receive(:[]).with(:readonly).and_return(false)
        allow(params).to receive(:[]).with(:force).and_return(false)

        allow(params).to receive(:[]).with(:force_for_new_devices).and_return(true)
        allow(params).to receive(:[]).with(:force_for_new_certificates).and_return(true)
        allow(params).to receive(:[]).with(:include_all_certificates).and_return(true)
      end

      describe "#can_force_include_all_devices?" do
        it "returns true if params ok" do
          # WHEN
          can_include_devices = Match::ProfileIncludes.can_force_include_all_devices?(params: params)

          # THEN
          expect(can_include_devices).to be(true)
        end

        it "returns false if readonly" do
          # GIVEN
          allow(params).to receive(:[]).with(:readonly).and_return(true)

          # WHEN
          can_include_devices = Match::ProfileIncludes.can_force_include_all_devices?(params: params)

          # THEN
          expect(can_include_devices).to be(false)
        end

        it "returns false if no force_for_new_devices" do
          # GIVEN
          allow(params).to receive(:[]).with(:force_for_new_devices).and_return(false)

          # WHEN
          can_include_devices = Match::ProfileIncludes.can_force_include_all_devices?(params: params)

          # THEN
          expect(can_include_devices).to be(false)
        end

        it "returns false if type is unsuitable" do
          # GIVEN
          allow(params).to receive(:[]).with(:type).and_return('appstore')

          # WHEN
          can_include_devices = Match::ProfileIncludes.can_force_include_all_devices?(params: params)

          # THEN
          expect(can_include_devices).to be(false)
        end
      end

      describe "#can_force_include_all_certificates?" do
        it "returns true if params ok" do
          # WHEN
          can_include_certs = Match::ProfileIncludes.can_force_include_all_certificates?(params: params)

          # THEN
          expect(can_include_certs).to be(true)
        end

        it "returns false if readonly" do
          # GIVEN
          allow(params).to receive(:[]).with(:readonly).and_return(true)

          # WHEN
          can_include_certs = Match::ProfileIncludes.can_force_include_all_certificates?(params: params)

          # THEN
          expect(can_include_certs).to be(false)
        end

        it "returns false if no force_for_new_devices" do
          # GIVEN
          allow(params).to receive(:[]).with(:force_for_new_certificates).and_return(false)

          # WHEN
          can_include_certs = Match::ProfileIncludes.can_force_include_all_certificates?(params: params)

          # THEN
          expect(can_include_certs).to be(false)
        end

        it "returns false if no include_all_certificates" do
          # GIVEN
          allow(params).to receive(:[]).with(:include_all_certificates).and_return(false)

          # WHEN
          can_include_certs = Match::ProfileIncludes.can_force_include_all_certificates?(params: params)

          # THEN
          expect(can_include_certs).to be(false)
        end

        it "returns false if type is unsuitable" do
          # GIVEN
          allow(params).to receive(:[]).with(:type).and_return('appstore')

          # WHEN
          can_include_certs = Match::ProfileIncludes.can_force_include_all_certificates?(params: params)

          # THEN
          expect(can_include_certs).to be(false)
        end
      end
    end
  end
end
