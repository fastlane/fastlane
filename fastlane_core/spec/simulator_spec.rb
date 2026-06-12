require 'open3'

describe FastlaneCore do
  describe FastlaneCore::Simulator do
    before do
      @valid_devices_json = JSON.generate({
        "devices" => {
          "com.apple.CoreSimulator.SimRuntime.iOS-7-1" => [
            { "name" => "iPhone 4s", "udid" => "8E3D97C4-1143-4E84-8D57-F697140F2ED0", "state" => "Shutdown", "isAvailable" => false },
            { "name" => "iPhone 5", "udid" => "65D0F571-1260-4241-9583-611EAF4D56AE", "state" => "Shutdown", "isAvailable" => false }
          ],
          "com.apple.CoreSimulator.SimRuntime.iOS-8-1" => [
            { "name" => "iPhone 4s", "udid" => "DBABD2A2-0144-44B0-8F93-263EB656FC13", "state" => "Shutdown", "isAvailable" => true },
            { "name" => "iPhone 5", "udid" => "0D80C781-8702-4156-855E-A9B737FF92D3", "state" => "Booted", "isAvailable" => true }
          ],
          "com.apple.CoreSimulator.SimRuntime.iOS-9-1" => [
            { "name" => "iPhone 6s Plus", "udid" => "BB65C267-FAE9-4CB7-AE31-A5D9BA393AF0", "state" => "Shutdown", "isAvailable" => true },
            { "name" => "Resizable iPad", "udid" => "B323CCB4-840B-4B26-B57B-71681D6C30C2", "state" => "Shutdown", "isAvailable" => false },
            { "name" => "iPad Air 2", "udid" => "961A7DF9-F442-4CA5-B28E-D96288D39DCA", "state" => "Shutdown", "isAvailable" => true }
          ],
          "com.apple.CoreSimulator.SimRuntime.tvOS-9-0" => [
            { "name" => "Apple TV 1080p", "udid" => "D239A51B-A61C-4B60-B4D6-B7EC16595128", "state" => "Shutdown", "isAvailable" => true }
          ],
          "com.apple.CoreSimulator.SimRuntime.watchOS-2-0" => [
            { "name" => "Apple Watch - 38mm", "udid" => "FE0C82A5-CDD2-4062-A62C-21278EEE32BB", "state" => "Shutdown", "isAvailable" => true },
            { "name" => "Apple Watch - 38mm", "udid" => "66D1BF17-3003-465F-A165-E6E3A565E5EB", "state" => "Booted", "isAvailable" => true }
          ]
        }
      })

      @valid_runtimes_json = JSON.generate({
        "runtimes" => [
          { "identifier" => "com.apple.CoreSimulator.SimRuntime.iOS-7-1", "version" => "7.1", "isAvailable" => false },
          { "identifier" => "com.apple.CoreSimulator.SimRuntime.iOS-8-1", "version" => "8.1", "isAvailable" => true },
          { "identifier" => "com.apple.CoreSimulator.SimRuntime.iOS-9-1", "version" => "9.1", "isAvailable" => true },
          { "identifier" => "com.apple.CoreSimulator.SimRuntime.tvOS-9-0", "version" => "9.0", "isAvailable" => true },
          { "identifier" => "com.apple.CoreSimulator.SimRuntime.watchOS-2-0", "version" => "2.0", "isAvailable" => true }
        ]
      })

      FastlaneCore::Simulator.clear_cache
    end

    # Helper to mock the two JSON simctl calls
    def mock_simctl_json(devices_json, runtimes_json)
      status = double('status', "success?": true)
      expect(Open3).to receive(:capture2).with('xcrun simctl list -j devices').and_return([devices_json, status])
      expect(Open3).to receive(:capture2).with('xcrun simctl list -j runtimes').and_return([runtimes_json, status])
    end

    it "can launch Simulator.app for a simulator device" do
      device = FastlaneCore::DeviceManager::Device.new(name: 'iPhone 5s',
                                                       udid: '3E67398C-AF70-4D77-A22C-D43AA8623FE3',
                                                    os_type: 'iOS',
                                                 os_version: '10.0',
                                                      state: 'Shutdown',
                                               is_simulator: true)

      simulator_path = File.join(FastlaneCore::Helper.xcode_path, 'Applications', 'Simulator.app')
      expected_command = "open -a #{simulator_path} --args -CurrentDeviceUDID #{device.udid}"

      expect(FastlaneCore::Helper).to receive(:backticks).with(expected_command, print: FastlaneCore::Globals.verbose?)

      FastlaneCore::Simulator.launch(device)
    end

    it "does not launch Simulator.app for a non-simulator device" do
      device = FastlaneCore::DeviceManager::Device.new(name: 'iPhone 5s',
                                                       udid: '3E67398C-AF70-4D77-A22C-D43AA8623FE3',
                                                    os_type: 'iOS',
                                                 os_version: '10.0',
                                                      state: 'Shutdown',
                                               is_simulator: false)

      expect(FastlaneCore::Helper).not_to(receive(:backticks))

      FastlaneCore::Simulator.launch(device)
    end

    it "raises an error if xcrun CLI prints garbage" do
      status = double('status', "success?": true)
      expect(Open3).to receive(:capture2).with('xcrun simctl list -j devices').and_return(['garbage', status])

      expect do
        devices = FastlaneCore::Simulator.all
      end.to raise_error("xcrun simctl not working.")
    end

    it "properly parses the simctl output and generates Device objects for iOS" do
      mock_simctl_json(@valid_devices_json, @valid_runtimes_json)

      devices = FastlaneCore::Simulator.all
      expect(devices.count).to eq(4)

      expect(devices[0]).to have_attributes(
        name: "iPhone 4s", os_version: "8.1",
        udid: "DBABD2A2-0144-44B0-8F93-263EB656FC13",
        state: "Shutdown"
      )
      expect(devices[1]).to have_attributes(
        name: "iPhone 5", os_version: "8.1",
        udid: "0D80C781-8702-4156-855E-A9B737FF92D3",
        state: "Booted"
      )
      expect(devices[2]).to have_attributes(
        name: "iPhone 6s Plus", os_version: "9.1",
        udid: "BB65C267-FAE9-4CB7-AE31-A5D9BA393AF0",
        state: "Shutdown"
      )
      expect(devices[3]).to have_attributes(
        name: "iPad Air 2", os_version: "9.1",
        udid: "961A7DF9-F442-4CA5-B28E-D96288D39DCA",
        state: "Shutdown"
      )
    end

    it "properly parses the simctl output and generates Device objects for tvOS" do
      mock_simctl_json(@valid_devices_json, @valid_runtimes_json)

      devices = FastlaneCore::SimulatorTV.all
      expect(devices.count).to eq(1)

      expect(devices[0]).to have_attributes(
        name: "Apple TV 1080p", os_version: "9.0",
        udid: "D239A51B-A61C-4B60-B4D6-B7EC16595128",
        state: "Shutdown"
      )
    end

    it "properly parses the simctl output and generates Device objects for watchOS" do
      mock_simctl_json(@valid_devices_json, @valid_runtimes_json)

      devices = FastlaneCore::SimulatorWatch.all
      expect(devices.count).to eq(2)

      expect(devices[0]).to have_attributes(
        name: "Apple Watch - 38mm", os_version: "2.0",
        udid: "FE0C82A5-CDD2-4062-A62C-21278EEE32BB",
        state: "Shutdown"
      )
      expect(devices[1]).to have_attributes(
        name: "Apple Watch - 38mm", os_version: "2.0",
        udid: "66D1BF17-3003-465F-A165-E6E3A565E5EB",
        state: "Booted"
      )
    end
  end
end
