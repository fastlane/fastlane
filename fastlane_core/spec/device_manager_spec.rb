require 'open3'

describe FastlaneCore do
  describe FastlaneCore::DeviceManager do
    before(:all) do
      @simctl_output = File.read('./fastlane_core/spec/fixtures/DeviceManagerSimctlOutputXcode7')
      @system_profiler_output = File.read('./fastlane_core/spec/fixtures/DeviceManagerSystem_profilerOutput')
      @instruments_output = File.read('./fastlane_core/spec/fixtures/DeviceManagerInstrumentsOutput')
      @system_profiler_output_items_without_items = File.read('./fastlane_core/spec/fixtures/DeviceManagerSystem_profilerOutputItemsWithoutItems')
      @system_profiler_output_usb_hub = File.read('./fastlane_core/spec/fixtures/DeviceManagerSystem_profilerOutputUsbHub')

      FastlaneCore::Simulator.clear_cache
    end

    it "raises an error if xcrun CLI prints garbage simulator" do
      response = "response"
      s = StringIO.new
      s.puts(response)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, s, nil, nil)
      allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, s, nil, nil)

      expect do
        devices = FastlaneCore::Simulator.all
      end.to raise_error("xcrun simctl not working.")
    end

    describe "properly parses the simctl output and generates Device objects for iOS simulator" do
      it "Xcode 7" do
        response = "response"
        expect(response).to receive(:read).and_return(@simctl_output)
        expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)
        thing = {}
        expect(thing).to receive(:read).and_return("line\n")
        allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, thing, nil, nil)

        devices = FastlaneCore::Simulator.all
        expect(devices.count).to eq(6)

        expect(devices[0]).to have_attributes(
          name: "iPhone 4s", os_type: "iOS", os_version: "8.1",
          udid: "DBABD2A2-0144-44B0-8F93-263EB656FC13",
          state: "Shutdown",
          is_simulator: true
        )
        expect(devices[1]).to have_attributes(
          name: "iPhone 5", os_type: "iOS", os_version: "8.1",
          udid: "0D80C781-8702-4156-855E-A9B737FF92D3",
          state: "Booted",
          is_simulator: true
        )
        expect(devices[2]).to have_attributes(
          name: "iPhone 6s Plus", os_type: "iOS", os_version: "9.1",
          udid: "BB65C267-FAE9-4CB7-AE31-A5D9BA393AF0",
          state: "Shutdown",
          is_simulator: true
        )
        expect(devices[3]).to have_attributes(
          name: "iPad Air", os_type: "iOS", os_version: "9.1",
          udid: "B61CB41D-354B-4991-992A-80AFFF1062E6",
          state: "Shutdown",
          is_simulator: true
        )
        expect(devices[4]).to have_attributes(
          name: "iPad Air 2", os_type: "iOS", os_version: "9.1",
          udid: "57836FE1-5443-4433-B164-A6C9EADAB3F9",
          state: "Shutdown",
          is_simulator: true
        )
        expect(devices[5]).to have_attributes(
          name: "iPad Pro", os_type: "iOS", os_version: "9.1",
          udid: "B1DDED8D-E449-461A-94A5-4146A1F58B20",
          state: "Shutdown",
          is_simulator: true
        )
      end

      it "Xcode 8" do
        response = "response"
        simctl_output = File.read('./fastlane_core/spec/fixtures/DeviceManagerSimctlOutputXcode8')
        expect(response).to receive(:read).and_return(simctl_output)
        expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)
        thing = {}
        expect(thing).to receive(:read).and_return("line\n")
        allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, thing, nil, nil)

        devices = FastlaneCore::Simulator.all
        expect(devices.count).to eq(12)

        expect(devices[-3]).to have_attributes(
          name: "iPad Air 2", os_type: "iOS", os_version: "10.0",
          udid: "0FDEB396-0582-438A-B09E-8F8F889DB632",
          state: "Shutdown",
          is_simulator: true
        )
        expect(devices[-2]).to have_attributes(
          name: "iPad Pro (9.7-inch)", os_type: "iOS", os_version: "10.0",
          udid: "C03658EC-1362-4D8D-A40A-45B1D7D5405E",
          state: "Shutdown",
          is_simulator: true
        )
        expect(devices[-1]).to have_attributes(
          name: "iPad Pro (12.9-inch)", os_type: "iOS", os_version: "10.0",
          udid: "CEF11EB3-79DF-43CB-896A-0F33916C8BDE",
          state: "Shutdown",
          is_simulator: true
        )
      end

      it 'Xcode 9' do
        response = "response"
        simctl_output = File.read('./fastlane_core/spec/fixtures/DeviceManagerSimctlOutputXcode9')
        expect(response).to receive(:read).and_return(simctl_output)
        expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)
        thing = {}
        expect(thing).to receive(:read).and_return("line\n")
        allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, thing, nil, nil)

        devices = FastlaneCore::Simulator.all
        expect(devices.count).to eq(15)

        expect(devices[-3]).to have_attributes(
          name: "iPad Pro (12.9-inch)", os_type: "iOS", os_version: "11.0",
          udid: "C7C55339-DE8F-4DA3-B94A-09879CB1E5B5",
          state: "Shutdown",
          is_simulator: true
        )
        expect(devices[-2]).to have_attributes(
          name: "iPad Pro (12.9-inch) (2nd generation)", os_type: "iOS", os_version: "11.0",
          udid: "D2408DE5-C74F-4AD1-93FA-CC083D438321",
          state: "Shutdown",
          is_simulator: true
        )
        expect(devices[-1]).to have_attributes(
          name: "iPad Pro (10.5-inch)", os_type: "iOS", os_version: "11.0",
          udid: "ED8B6B96-11CC-4848-93B8-4D5D627ABF7E",
          state: "Shutdown",
          is_simulator: true
        )
      end
    end

    it "properly parses the simctl output and generates Device objects for tvOS simulator" do
      response = "response"
      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)
      thing = {}
      expect(thing).to receive(:read).and_return("line\n")
      allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, thing, nil, nil)

      devices = FastlaneCore::SimulatorTV.all
      expect(devices.count).to eq(1)

      expect(devices[0]).to have_attributes(
        name: "Apple TV 1080p", os_type: "tvOS", os_version: "9.0",
        udid: "D239A51B-A61C-4B60-B4D6-B7EC16595128",
        state: "Shutdown",
        is_simulator: true
      )
    end

    it "properly parses the simctl output and generates Device objects for watchOS simulator" do
      response = "response"
      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)
      thing = {}
      expect(thing).to receive(:read).and_return("line\n")
      allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, thing, nil, nil)

      devices = FastlaneCore::SimulatorWatch.all
      expect(devices.count).to eq(2)

      expect(devices[0]).to have_attributes(
        name: "Apple Watch - 38mm", os_type: "watchOS", os_version: "2.0",
        udid: "FE0C82A5-CDD2-4062-A62C-21278EEE32BB",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[1]).to have_attributes(
        name: "Apple Watch - 38mm", os_type: "watchOS", os_version: "2.0",
        udid: "66D1BF17-3003-465F-A165-E6E3A565E5EB",
        state: "Booted",
        is_simulator: true
      )
    end

    it "properly parses the simctl output and generates Device objects for all simulators" do
      response = "response"
      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)
      thing = {}
      expect(thing).to receive(:read).and_return("line\n")
      allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, thing, nil, nil)

      devices = FastlaneCore::DeviceManager.simulators
      expect(devices.count).to eq(9)

      expect(devices[0]).to have_attributes(
        name: "iPhone 4s", os_type: "iOS", os_version: "8.1",
        udid: "DBABD2A2-0144-44B0-8F93-263EB656FC13",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[1]).to have_attributes(
        name: "iPhone 5", os_type: "iOS", os_version: "8.1",
        udid: "0D80C781-8702-4156-855E-A9B737FF92D3",
        state: "Booted",
        is_simulator: true
      )
      expect(devices[2]).to have_attributes(
        name: "iPhone 6s Plus", os_type: "iOS", os_version: "9.1",
        udid: "BB65C267-FAE9-4CB7-AE31-A5D9BA393AF0",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[3]).to have_attributes(
        name: "iPad Air", os_type: "iOS", os_version: "9.1",
        udid: "B61CB41D-354B-4991-992A-80AFFF1062E6",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[6]).to have_attributes(
        name: "Apple TV 1080p", os_type: "tvOS", os_version: "9.0",
        udid: "D239A51B-A61C-4B60-B4D6-B7EC16595128",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[7]).to have_attributes(
        name: "Apple Watch - 38mm", os_type: "watchOS", os_version: "2.0",
        udid: "FE0C82A5-CDD2-4062-A62C-21278EEE32BB",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[8]).to have_attributes(
        name: "Apple Watch - 38mm", os_type: "watchOS", os_version: "2.0",
        udid: "66D1BF17-3003-465F-A165-E6E3A565E5EB",
        state: "Booted",
        is_simulator: true
      )
    end

    it "properly parses system_profiler and instruments output and generates Device objects for iOS" do
      response = "response"
      expect(response).to receive(:read).and_return(@system_profiler_output)
      expect(Open3).to receive(:popen3).with("system_profiler SPUSBDataType -xml").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@instruments_output)
      expect(Open3).to receive(:popen3).with("instruments -s devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::DeviceManager.connected_devices('iOS')
      expect(devices.count).to eq(1)

      expect(devices[0]).to have_attributes(
        name: "Matthew's iPhone", os_type: "iOS", os_version: "9.3",
        udid: "f0f9f44e7c2dafbae53d1a83fe27c37418ffffff",
        state: "Booted",
        is_simulator: false
      )
    end

    it "properly parses system_profiler output with entries that don't contain _items" do
      response = "response"
      expect(response).to receive(:read).and_return(@system_profiler_output_items_without_items)
      expect(Open3).to receive(:popen3).with("system_profiler SPUSBDataType -xml").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::DeviceManager.connected_devices('iOS')
      expect(devices).to be_empty
    end

    it "properly finds devices in system_profiler output when connected via USB hubs" do
      response = "response"
      expect(response).to receive(:read).and_return(@system_profiler_output_usb_hub)
      expect(Open3).to receive(:popen3).with("system_profiler SPUSBDataType -xml").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@instruments_output)
      expect(Open3).to receive(:popen3).with("instruments -s devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::DeviceManager.connected_devices('iOS')
      expect(devices.count).to eq(1)
      expect(devices[0]).to have_attributes(
        name: "Matthew's iPhone", os_type: "iOS", os_version: "9.3",
        udid: "f0f9f44e7c2dafbae53d1a83fe27c37418ffffff",
        state: "Booted",
        is_simulator: false
      )
    end

    it "properly parses system_profiler and instruments output and generates Device objects for tvOS" do
      response = "response"
      expect(response).to receive(:read).and_return(@system_profiler_output)
      expect(Open3).to receive(:popen3).with("system_profiler SPUSBDataType -xml").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@instruments_output)
      expect(Open3).to receive(:popen3).with("instruments -s devices").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::DeviceManager.connected_devices('tvOS')
      expect(devices.count).to eq(1)

      expect(devices[0]).to have_attributes(
        name: "Matthew's Apple TV", os_type: "tvOS", os_version: "9.1",
        udid: "82f1fb5c8362ee9eb89a9c2c6829fa0563ffffff",
        state: "Booted",
        is_simulator: false
      )
    end

    it "properly parses output for all iOS devices" do
      response = "response"
      expect(response).to receive(:read).and_return(@system_profiler_output)
      expect(Open3).to receive(:popen3).with("system_profiler SPUSBDataType -xml").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@instruments_output)
      expect(Open3).to receive(:popen3).with("instruments -s devices").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)
      thing = {}
      expect(thing).to receive(:read).and_return("line\n")
      allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, thing, nil, nil)

      devices = FastlaneCore::DeviceManager.all('iOS')
      expect(devices.count).to eq(7)

      expect(devices[0]).to have_attributes(
        name: "Matthew's iPhone", os_type: "iOS", os_version: "9.3",
        udid: "f0f9f44e7c2dafbae53d1a83fe27c37418ffffff",
        state: "Booted",
        is_simulator: false
      )
      expect(devices[1]).to have_attributes(
        name: "iPhone 4s", os_type: "iOS", os_version: "8.1",
        udid: "DBABD2A2-0144-44B0-8F93-263EB656FC13",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[2]).to have_attributes(
        name: "iPhone 5", os_type: "iOS", os_version: "8.1",
        udid: "0D80C781-8702-4156-855E-A9B737FF92D3",
        state: "Booted",
        is_simulator: true
      )
      expect(devices[3]).to have_attributes(
        name: "iPhone 6s Plus", os_type: "iOS", os_version: "9.1",
        udid: "BB65C267-FAE9-4CB7-AE31-A5D9BA393AF0",
        state: "Shutdown",
        is_simulator: true
      )
      expect(devices[4]).to have_attributes(
        name: "iPad Air", os_type: "iOS", os_version: "9.1",
        udid: "B61CB41D-354B-4991-992A-80AFFF1062E6",
        state: "Shutdown",
        is_simulator: true
      )
    end

    it "properly parses output for all tvOS devices" do
      response = "response"
      expect(response).to receive(:read).and_return(@system_profiler_output)
      expect(Open3).to receive(:popen3).with("system_profiler SPUSBDataType -xml").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@instruments_output)
      expect(Open3).to receive(:popen3).with("instruments -s devices").and_yield(nil, response, nil, nil)

      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)
      thing = {}
      expect(thing).to receive(:read).and_return("line\n")
      allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, thing, nil, nil)

      devices = FastlaneCore::DeviceManager.all('tvOS')
      expect(devices.count).to eq(2)

      expect(devices[0]).to have_attributes(
        name: "Matthew's Apple TV", os_type: "tvOS", os_version: "9.1",
        udid: "82f1fb5c8362ee9eb89a9c2c6829fa0563ffffff",
        state: "Booted",
        is_simulator: false
      )
      expect(devices[1]).to have_attributes(
        name: "Apple TV 1080p", os_type: "tvOS", os_version: "9.0",
        udid: "D239A51B-A61C-4B60-B4D6-B7EC16595128",
        state: "Shutdown",
        is_simulator: true
      )
    end

    it "parses runtime information properly to get the exact version information" do
      response = "response"
      expect(response).to receive(:read).and_return(@simctl_output)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)
      thing = {}
      expect(thing).to receive(:read).and_return("== Runtimes ==\ntvOS 9.0 (9.0.1 - 13A345) - com.apple.CoreSimulator.SimRuntime.tvOS-9-0\n")
      allow(Open3).to receive(:popen3).with("xcrun simctl list runtimes").and_yield(nil, thing, nil, nil)

      devices = FastlaneCore::SimulatorTV.all
      expect(devices.count).to eq(1)

      expect(devices[0]).to have_attributes(
        name: "Apple TV 1080p", os_type: "tvOS", os_version: "9.0.1",
        udid: "D239A51B-A61C-4B60-B4D6-B7EC16595128",
        state: "Shutdown",
        is_simulator: true
      )
    end
  end
end
