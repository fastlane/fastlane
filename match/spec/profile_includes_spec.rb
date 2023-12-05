describe Match do
  describe Match::ProfileIncludes do
    describe "counts" do
      let(:portal_profile) { double("profile") }
      let(:profile_device) { double("profile_device") }
      let(:profile_certificate) { double("profile_certificate") }

      before do
        allow(portal_profile).to receive(:devices).and_return([profile_device])
        allow(portal_profile).to receive(:certificates).and_return([profile_certificate])
      end

      describe "#device_count_different?" do
        it "returns false if device count same" do
          # WHEN
          device_count_different = Match::ProfileIncludes.device_count_different?(portal_profile: portal_profile, platform: 'ios', include_mac_in_profiles: true, cached_devices: [1])

          # THEN
          expect(device_count_different).to be(false)
        end

        it "returns true if device count differs" do
          # WHEN
          device_count_different = Match::ProfileIncludes.device_count_different?(portal_profile: portal_profile, platform: 'ios', include_mac_in_profiles: true, cached_devices: [1, 2])

          # THEN
          expect(device_count_different).to be(true)
        end
      end

      describe "#certificate_count_different?" do
        it "returns false if certificate count same" do
          # GIVEN
          allow(profile_certificate).to receive(:valid?).and_return(true)

          # WHEN
          certificate_count_different = Match::ProfileIncludes.certificate_count_different?(portal_profile: portal_profile, platform: 'ios', cached_certificates: [1])

          # THEN
          expect(certificate_count_different).to be(false)
        end

        it "returns true if certificate count differs with valid cert" do
          # GIVEN
          allow(profile_certificate).to receive(:valid?).and_return(true)

          # WHEN
          certificate_count_different = Match::ProfileIncludes.certificate_count_different?(portal_profile: portal_profile, platform: 'ios', cached_certificates: [1, 2])

          # THEN
          expect(certificate_count_different).to be(true)
        end

        it "returns true if certificate count differs with invalid cert" do
          # GIVEN
          allow(profile_certificate).to receive(:valid?).and_return(false)

          # WHEN
          certificate_count_different = Match::ProfileIncludes.certificate_count_different?(portal_profile: portal_profile, platform: 'ios', cached_certificates: [1])

          # THEN
          expect(certificate_count_different).to be(true)
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

        it "returns false if type is unsutable" do
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

        it "returns false if type is unsutable" do
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
