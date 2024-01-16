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
        describe "certificate_id is not specified (multiple)" do
          it "returns false if certificates are the same" do
            # WHEN
            certificates_differ = Match::ProfileIncludes.certificates_differ?(portal_profile: portal_profile, platform: 'ios', certificate_id: nil, cached_certificates: [profile_certificate])

            # THEN
            expect(certificates_differ).to be(false)
          end

          it "returns true if certs differ even when the count is the same" do
            # GIVEN
            portal_cert = double("portal_cert")
            allow(portal_cert).to receive(:id).and_return(2)

            # WHEN
            certificates_differ = Match::ProfileIncludes.certificates_differ?(portal_profile: portal_profile, platform: 'ios', certificate_id: nil, cached_certificates: [portal_cert])

            # THEN
            expect(certificates_differ).to be(true)
          end

          it "returns true if certs differ" do
            # GIVEN
            portal_cert = double("portal_cert")
            allow(portal_cert).to receive(:id).and_return(2)

            # WHEN
            certificates_differ = Match::ProfileIncludes.certificates_differ?(portal_profile: portal_profile, platform: 'ios', certificate_id: nil, cached_certificates: [profile_certificate, portal_cert])

            # THEN
            expect(certificates_differ).to be(true)
          end
        end

        describe "certificate_id is specified (single)" do
          it "returns true if certs differ" do
            # GIVEN
            portal_cert = double("portal_cert")
            allow(portal_cert).to receive(:id).and_return(2)

            # WHEN
            certificates_differ = Match::ProfileIncludes.certificates_differ?(portal_profile: portal_profile, platform: 'ios', certificate_id: portal_cert.id, cached_certificates: [portal_cert, profile_certificate])

            # THEN
            expect(certificates_differ).to be(true)
          end

          it "returns false if certs equal" do
            # GIVEN
            portal_cert = double("portal_cert")
            allow(portal_cert).to receive(:id).and_return(2)

            # WHEN
            certificates_differ = Match::ProfileIncludes.certificates_differ?(portal_profile: portal_profile, platform: 'ios', certificate_id: profile_certificate.id, cached_certificates: [profile_certificate, portal_cert])

            # THEN
            expect(certificates_differ).to be(false)
          end
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

      describe "#can_force_include_new_certificates?" do
        it "returns true if params ok" do
          # WHEN
          can_include_certs = Match::ProfileIncludes.can_force_include_new_certificates?(params: params)

          # THEN
          expect(can_include_certs).to be(true)
        end

        it "returns false if readonly" do
          # GIVEN
          allow(params).to receive(:[]).with(:readonly).and_return(true)

          # WHEN
          can_include_certs = Match::ProfileIncludes.can_force_include_new_certificates?(params: params)

          # THEN
          expect(can_include_certs).to be(false)
        end

        it "returns false if no force_for_new_certificates" do
          # GIVEN
          allow(params).to receive(:[]).with(:force_for_new_certificates).and_return(false)

          # WHEN
          can_include_certs = Match::ProfileIncludes.can_force_include_new_certificates?(params: params)

          # THEN
          expect(can_include_certs).to be(false)
        end
      end
    end

    describe "should's" do
      describe "#should_force_include_new_certificates?" do
        let(:params) { double("params") }
        let(:portal_profile) { double("portal_profile") }

        before do
          allow(params).to receive(:[]).with(:type).and_return('development')

          allow(params).to receive(:[]).with(:readonly).and_return(false)
          allow(params).to receive(:[]).with(:force).and_return(false)

          allow(params).to receive(:[]).with(:force_for_new_certificates).and_return(true)
        end

        it "returns true if a single certificate doesn't match" do
          # GIVEN
          allow(params).to receive(:[]).with(:force_for_new_certificates).and_return(true)
          allow(params).to receive(:[]).with(:platform).and_return('ios')

          profile_certificate = "profile_certificate"
          allow(portal_profile).to receive(:certificates).and_return([profile_certificate])
          profile_certificate_id = "profile_certificate_id"
          allow(profile_certificate).to receive(:id).and_return(profile_certificate_id)

          portal_certificate = "portal_certificate"
          portal_certificate_id = "portal_certificate_id"
          allow(portal_certificate).to receive(:id).and_return(portal_certificate_id)

          # WHEN
          should_force_new_certs = Match::ProfileIncludes.should_force_include_new_certificates?(params: params, portal_profile: portal_profile, certificate_id: portal_certificate_id, cached_certificates: [portal_certificate])

          # THEN
          expect(should_force_new_certs).to be(true)
        end

        it "returns false if a single certificate match" do
          # GIVEN
          allow(params).to receive(:[]).with(:force_for_new_certificates).and_return(true)
          allow(params).to receive(:[]).with(:platform).and_return('ios')

          common_certificate = "common_certificate"
          allow(portal_profile).to receive(:certificates).and_return([common_certificate])
          common_certificate_id = "certificate_id"
          allow(common_certificate).to receive(:id).and_return(common_certificate_id)

          # WHEN
          should_force_new_certs = Match::ProfileIncludes.should_force_include_new_certificates?(params: params, portal_profile: portal_profile, certificate_id: common_certificate_id, cached_certificates: [common_certificate])

          # THEN
          expect(should_force_new_certs).to be(false)
        end
      end
    end
  end
end
