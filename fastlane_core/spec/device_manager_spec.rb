require 'open3'

describe FastlaneCore do
  describe FastlaneCore::DeviceManager do
    before(:all) do
      @simctl_output = File.read('./spec/fixtures/DeviceManagerSimctlOutput')
      @system_profiler_output = File.read('./spec/fixtures/DeviceManagerSystem_profilerOutput')
      @instruments_output = File.read('./spec/fixtures/DeviceManagerInstrumentsOutput')

      FastlaneCore::Simulator.clear_cache
    end

    it "raises an error if xcrun CLI prints garbage simulator" do
      response = "response"
      expect(response).to receive(:read).and_return("💩")
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

      expect do
        devices = FastlaneCore::Simulator.all
      end.to raise_error("xcrun simctl not working.")
    end

    it "properly parses the simctl output and generates Device objects for iOS simulator" do
      response = "response"
      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::Simulator.all
      expect(devices.count).to eq(4)

      expect(devices[0]).to have_attributes(
        name: "iPhone 4s", os_version: "8.1",
        udid: "DBABD2A2-0144-44B0-8F93-263EB656FC13",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[1]).to have_attributes(
        name: "iPhone 5", os_version: "8.1",
        udid: "0D80C781-8702-4156-855E-A9B737FF92D3",
        state: "Booted",
        is_simulator: true
      )
      expect(devices[2]).to have_attributes(
        name: "iPhone 6s Plus", os_version: "9.1",
        udid: "BB65C267-FAE9-4CB7-AE31-A5D9BA393AF0",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[3]).to have_attributes(
        name: "iPad Air 2", os_version: "9.1",
        udid: "961A7DF9-F442-4CA5-B28E-D96288D39DCA",
        state: "Shutdown",
        is_simulator: true
      )
    end

    it "properly parses the simctl output and generates Device objects for tvOS simulator" do
      response = "response"
      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::SimulatorTV.all
      expect(devices.count).to eq(1)

      expect(devices[0]).to have_attributes(
        name: "Apple TV 1080p", os_version: "9.0",
        udid: "D239A51B-A61C-4B60-B4D6-B7EC16595128",
        state: "Shutdown",
        is_simulator: true
      )
    end

    it "properly parses the simctl output and generates Device objects for watchOS simulator" do
      response = "response"
      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::SimulatorWatch.all
      expect(devices.count).to eq(2)

      expect(devices[0]).to have_attributes(
        name: "Apple Watch - 38mm", os_version: "2.0",
        udid: "FE0C82A5-CDD2-4062-A62C-21278EEE32BB",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[1]).to have_attributes(
        name: "Apple Watch - 38mm", os_version: "2.0",
        udid: "66D1BF17-3003-465F-A165-E6E3A565E5EB",
        state: "Booted",
        is_simulator: true
      )
    end

    it "properly parses the simctl output and generates Device objects for all simulators" do
      response = "response"
      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::DeviceManager.simulators
      expect(devices.count).to eq(7)

      expect(devices[0]).to have_attributes(
        name: "iPhone 4s", os_version: "8.1",
        udid: "DBABD2A2-0144-44B0-8F93-263EB656FC13",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[1]).to have_attributes(
        name: "iPhone 5", os_version: "8.1",
        udid: "0D80C781-8702-4156-855E-A9B737FF92D3",
        state: "Booted",
        is_simulator: true
      )
      expect(devices[2]).to have_attributes(
        name: "iPhone 6s Plus", os_version: "9.1",
        udid: "BB65C267-FAE9-4CB7-AE31-A5D9BA393AF0",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[3]).to have_attributes(
        name: "iPad Air 2", os_version: "9.1",
        udid: "961A7DF9-F442-4CA5-B28E-D96288D39DCA",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[4]).to have_attributes(
        name: "Apple TV 1080p", os_version: "9.0",
        udid: "D239A51B-A61C-4B60-B4D6-B7EC16595128",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[5]).to have_attributes(
        name: "Apple Watch - 38mm", os_version: "2.0",
        udid: "FE0C82A5-CDD2-4062-A62C-21278EEE32BB",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[6]).to have_attributes(
        name: "Apple Watch - 38mm", os_version: "2.0",
        udid: "66D1BF17-3003-465F-A165-E6E3A565E5EB",
        state: "Booted",
        is_simulator: true
      )
    end

    it "property parses system_profiler and instruments output and generates Device objects for iOS" do
      response = "response"
      expect(response).to receive(:read).and_return(@system_profiler_output)
      expect(Open3).to receive(:popen3).with("system_profiler SPUSBDataType -xml").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@instruments_output)
      expect(Open3).to receive(:popen3).with("instruments -s devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::DeviceManager.connected_devices('iOS')
      expect(devices.count).to eq(1)

      expect(devices[0]).to have_attributes(
        name: "Matthew's iPhone", os_version: "9.3",
        udid: "f0f9f44e7c2dafbae53d1a83fe27c37418ffffff",
        state: "Booted",
        is_simulator: false
      )
    end

    it "property parses system_profiler and instruments output and generates Device objects for tvOS" do
      response = "response"
      expect(response).to receive(:read).and_return(@system_profiler_output)
      expect(Open3).to receive(:popen3).with("system_profiler SPUSBDataType -xml").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@instruments_output)
      expect(Open3).to receive(:popen3).with("instruments -s devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::DeviceManager.connected_devices('tvOS')
      expect(devices.count).to eq(1)

      expect(devices[0]).to have_attributes(
        name: "Matthew's Apple TV", os_version: "9.1",
        udid: "82f1fb5c8362ee9eb89a9c2c6829fa0563ffffff",
        state: "Booted",
        is_simulator: false
      )
    end

    it "property parses output for all iOS devices" do
      response = "response"
      expect(response).to receive(:read).and_return(@system_profiler_output)
      expect(Open3).to receive(:popen3).with("system_profiler SPUSBDataType -xml").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@instruments_output)
      expect(Open3).to receive(:popen3).with("instruments -s devices").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::DeviceManager.all('iOS')
      expect(devices.count).to eq(5)

      expect(devices[0]).to have_attributes(
        name: "Matthew's iPhone", os_version: "9.3",
        udid: "f0f9f44e7c2dafbae53d1a83fe27c37418ffffff",
        state: "Booted",
        is_simulator: false
      )
      expect(devices[1]).to have_attributes(
        name: "iPhone 4s", os_version: "8.1",
        udid: "DBABD2A2-0144-44B0-8F93-263EB656FC13",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[2]).to have_attributes(
        name: "iPhone 5", os_version: "8.1",
        udid: "0D80C781-8702-4156-855E-A9B737FF92D3",
        state: "Booted",
        is_simulator: true
      )
      expect(devices[3]).to have_attributes(
        name: "iPhone 6s Plus", os_version: "9.1",
        udid: "BB65C267-FAE9-4CB7-AE31-A5D9BA393AF0",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[4]).to have_attributes(
        name: "iPad Air 2", os_version: "9.1",
        udid: "961A7DF9-F442-4CA5-B28E-D96288D39DCA",
        state: "Shutdown",
        is_simulator: true
      )
    end

    it "property parses output for all tvOS devices" do
      response = "response"
      expect(response).to receive(:read).and_return(@system_profiler_output)
      expect(Open3).to receive(:popen3).with("system_profiler SPUSBDataType -xml").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@instruments_output)
      expect(Open3).to receive(:popen3).with("instruments -s devices").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::DeviceManager.all('tvOS')
      expect(devices.count).to eq(2)

      expect(devices[0]).to have_attributes(
        name: "Matthew's Apple TV", os_version: "9.1",
        udid: "82f1fb5c8362ee9eb89a9c2c6829fa0563ffffff",
        state: "Booted",
        is_simulator: false
      )
      expect(devices[1]).to have_attributes(
        name: "Apple TV 1080p", os_version: "9.0",
        udid: "D239A51B-A61C-4B60-B4D6-B7EC16595128",
        state: "Shutdown",
        is_simulator: true
      )
    end
  end
end
