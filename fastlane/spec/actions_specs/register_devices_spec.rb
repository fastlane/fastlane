describe Fastlane do
  describe Fastlane::FastFile do
    describe "Register Devices Action" do
      let(:devices_file_with_platform) do
        File.absolute_path('./fastlane/spec/fixtures/actions/register_devices/devices-list-with-platform.txt')
      end
      let(:devices_file_without_platform) do
        File.absolute_path('./fastlane/spec/fixtures/actions/register_devices/devices-list-without-platform.txt')
      end

      let(:existing_device) { double }
      let(:fake_devices) { [existing_device] }

      let(:fake_credentials) { double }

      before(:each) do
        allow(fake_credentials).to receive(:user)
        allow(fake_credentials).to receive(:password)

        allow(CredentialsManager::AccountManager).to receive(:new).and_return(fake_credentials)
        allow(Spaceship::Portal).to receive(:login)
        allow(Spaceship::Portal).to receive(:select_team)

        allow(existing_device).to receive(:udid).and_return("A123456789012345678901234567890123456789")
      end

      it "registers devices with file with platform" do
        expect(Spaceship::Device).to receive(:all).and_return(fake_devices).with(mac: false)
        expect(Spaceship::Device).to receive(:all).and_return(fake_devices).with(mac: true)

        expect(Fastlane::Actions::RegisterDevicesAction).to receive(:try_create_device).with(
          name: 'NAME2',
          udid: 'B123456789012345678901234567890123456789',
          mac: false
        )
        expect(Fastlane::Actions::RegisterDevicesAction).to receive(:try_create_device).with(
          name: 'NAME3',
          udid: 'A5B5CD50-14AB-5AF7-8B78-AB4751AB10A8',
          mac: true
        )
        expect(Fastlane::Actions::RegisterDevicesAction).to receive(:try_create_device).with(
          name: 'NAME4',
          udid: 'A5B5CD50-14AB-5AF7-8B78-AB4751AB10A7',
          mac: true
        )

        result = Fastlane::FastFile.new.parse("lane :test do
            register_devices(
              username: 'test@test.com',
              devices_file: '#{devices_file_with_platform}'
            )
          end").runner.execute(:test)
      end

      it "registers devices for ios with file without platform" do
        expect(Spaceship::Device).to receive(:all).and_return(fake_devices).with(mac: false)

        expect(Fastlane::Actions::RegisterDevicesAction).to receive(:try_create_device).with(
          name: 'NAME2',
          udid: 'B123456789012345678901234567890123456789',
          mac: false
        )

        result = Fastlane::FastFile.new.parse("lane :test do
            register_devices(
              username: 'test@test.com',
              devices_file: '#{devices_file_without_platform}',
              platform: 'ios'
            )
          end").runner.execute(:test)
      end

      it "registers devices for mac with file without platform" do
        expect(Spaceship::Device).to receive(:all).and_return(fake_devices).with(mac: true)

        expect(Fastlane::Actions::RegisterDevicesAction).to receive(:try_create_device).with(
          name: 'NAME2',
          udid: 'B123456789012345678901234567890123456789',
          mac: true
        )

        result = Fastlane::FastFile.new.parse("lane :test do
            register_devices(
              username: 'test@test.com',
              devices_file: '#{devices_file_without_platform}',
              platform: 'mac'
            )
          end").runner.execute(:test)
      end
    end
  end
end
