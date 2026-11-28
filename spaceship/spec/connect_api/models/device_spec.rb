describe Spaceship::ConnectAPI::Device do
  include_examples "common spaceship login"

  describe '#client' do
    it '#get_devices' do
      response = Spaceship::ConnectAPI.get_devices
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(3)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::Device)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.device_class).to eq("IPHONE")
      expect(model.model).to eq("iPhone 8")
      expect(model.name).to eq("Josh's iPhone")
      expect(model.platform).to eq("IOS")
      expect(model.status).to eq("ENABLED")
      expect(model.udid).to eq("184098239048390489012849018")
      expect(model.added_date).to eq("2018-10-10T01:43:27.000+0000")

      expect(model.enabled?).to eq(true)

      model.status = "DISABLED"
      expect(model.enabled?).to eq(false)
    end

    it '#find_by_udid with an existing enabled udid' do
      udid = "184098239048390489012849018"
      existing_device = Spaceship::ConnectAPI::Device.find_by_udid(udid)
      expect(existing_device.udid).to eq(udid)
    end

    it '#find_by_udid with missing udid because it is a disabled udid' do
      disabled_udid = "5233342324433534345354534"
      non_existing_device = Spaceship::ConnectAPI::Device.find_by_udid(disabled_udid, include_disabled: false)
      expect(non_existing_device).to eq(nil)
    end

    it '#find_by_udid with non-existing udid' do
      udid = "424242"
      non_existing_device = Spaceship::ConnectAPI::Device.find_by_udid(udid)
      expect(non_existing_device).to eq(nil)
    end

    it '#find_by_udid with an existing disabled udid with include_disabled parameter set to true' do
      udid = "5233342324433534345354534"
      existing_device = Spaceship::ConnectAPI::Device.find_by_udid(udid, include_disabled: true)
      expect(existing_device.enabled?).to eq(false)
      expect(existing_device.udid).to eq(udid)
    end

    it '#enable an existing disabled udid' do
      udid = "5233342324433534345354534"
      existing_device = Spaceship::ConnectAPI::Device.enable(udid)
      expect(existing_device.enabled?).to eq(true)
      expect(existing_device.udid).to eq(udid)
    end

    it '#disable an existing disabled udid' do
      udid = "184098239048390489012849018"
      existing_device = Spaceship::ConnectAPI::Device.disable(udid)
      expect(existing_device.enabled?).to eq(false)
      expect(existing_device.udid).to eq(udid)
    end

    it '#rename an existing disabled udid' do
      udid = "5843758273957239847298374982"
      new_name = "renamed device"
      existing_device = Spaceship::ConnectAPI::Device.rename(udid, new_name)
      expect(existing_device.name).to eq(new_name)
      expect(existing_device.udid).to eq(udid)
    end
  end

  describe '.devices_for_platform with include_mac_in_profiles' do
    def device(device_class, udid, platform)
      Spaceship::ConnectAPI::Device.new("id-#{udid}", { "deviceClass" => device_class, "udid" => udid, "platform" => platform, "status" => "ENABLED" })
    end

    # The API reports Apple silicon Macs as MAC; only their UDID format tells them from Intel Macs
    let(:iphone) { device("IPHONE", "00008030-000A1B2C3D4E5F60", "IOS") }
    let(:silicon_mac) { device("MAC", "00008103-000A1B2C3D4E5F61", "MAC_OS") }
    let(:intel_mac) { device("MAC", "A1B2C3D4-E5F6-0123-4567-89ABCDEF0123", "MAC_OS") }

    before do
      allow(Spaceship::ConnectAPI::Device).to receive(:all).and_return([iphone, silicon_mac, intel_mac])
    end

    it 'adds Apple silicon Macs, not Intel ones, to iOS profiles' do
      devices = described_class.devices_for_platform(platform: :ios, include_mac_in_profiles: true)
      expect(devices.map(&:udid)).to eq([iphone.udid, silicon_mac.udid])
    end

    it 'adds no Mac without it' do
      devices = described_class.devices_for_platform(platform: :ios, include_mac_in_profiles: false)
      expect(devices.map(&:udid)).to eq([iphone.udid])
    end
  end
end
