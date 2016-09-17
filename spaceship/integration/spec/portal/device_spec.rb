describe Spaceship do
  describe Spaceship::Portal do
    describe Spaceship::Portal::Device do
      def expect_ios_device(device, type = nil)
        expect(device.id).to match_apple_ten_char_id
        expect(device.name).to_not be_empty
        expect(device.udid).to match_udid
        expect(device.platform).to eq('ios')
        expect(device.status).to_not be_nil
        if type
          expect(device.device_type).to eq(type)
        else
          expect(device.device_type).to_not be_nil
        end
      end

      let(:device) { Spaceship::Portal.device }

      before(:all) do
        @devices = Spaceship::Portal.device.all
      end

      it 'finds devices on the portal' do
        expect(@devices).to_not be_empty
      end

      it 'fetched devices have reasonable data' do
        device = @devices.first
        expect_ios_device(device)
      end

      it 'fetches devices of type iPod' do
        devices = Spaceship::Portal.device.all_ipod_touches
        expect(devices).to_not be_empty

        device = devices.first
        expect_ios_device(device, 'ipod')
      end

      it 'fetches devices of type iPhone' do
        devices = Spaceship::Portal.device.all_iphones
        expect(devices).to_not be_empty

        device = devices.first
        expect_ios_device(device, 'iphone')
      end

      it 'fetches devices of type iPad' do
        devices = Spaceship::Portal.device.all_ipads
        expect(devices).to_not be_empty

        device = devices.first
        expect_ios_device(device, 'ipad')
      end

      it 'fetches devices of type Apple TV' do
        devices = Spaceship::Portal.device.all_apple_tvs
        expect(devices).to_not be_empty

        device = devices.first
        expect_ios_device(device, 'tvOS')
      end

      it 'fetches devices of type Apple Watch' do
        devices = Spaceship::Portal.device.all_watches
        expect(devices).to_not be_empty

        device = devices.first
        expect_ios_device(device, 'watch')
      end
    end
  end
end
