require 'open3'

describe FastlaneCore do
  describe FastlaneCore::Simulator, now: true do
    before do
      @valid_simulators = '{
  "devices" : {
    "iOS 9.1" : [
      {
        "state" : "Shutdown",
        "availability" : "(available)",
        "name" : "iPhone 4s",
        "udid" : "81513CB9-9DC7-4D57-80EC-ACAF7E3E2174"
      },
      {
        "state" : "Shutdown",
        "availability" : "(available)",
        "name" : "iPhone 5",
        "udid" : "967F93D1-51A8-4BD8-80AE-849CF37EA2B5"
      },
      {
        "state" : "Shutdown",
        "availability" : "(available)",
        "name" : "iPhone 5s",
        "udid" : "705E930A-5C0C-4D85-8E01-D39528E64247"
      },
      {
        "state" : "Shutdown",
        "availability" : "(available)",
        "name" : "iPhone 6",
        "udid" : "867DB37B-3662-4F7D-BDD5-2E2C3E9F01B0"
      }
    ],
    "tvOS 9.0" : [
      {
        "state" : "Shutdown",
        "availability" : "(available)",
        "name" : "iPhone 6",
        "udid" : "867DB37B-3662-4F7D-BDD5-2E2C3E9F01B0"
      }
    ],
    "watchOS 2.0" : [
      {
        "state" : "Shutdown",
        "availability" : "(available)",
        "name" : "iPhone 6",
        "udid" : "867DB37B-3662-4F7D-BDD5-2E2C3E9F01B0"
      }
    ],
    "com.apple.CoreSimulator.SimRuntime.iOS-8-2" : [
      {
        "state" : "Shutdown",
        "availability" : " (unavailable, runtime profile not found)",
        "name" : "iPhone 4s",
        "udid" : "AE7BC950-457B-4195-9B83-0DB3C12CA716"
      }
    ]
  }
}'
      FastlaneCore::Simulator.clear_cache
    end

    it "raises an error if xcrun CLI prints garbage" do
      response = "response"
      expect(response).to receive(:read).and_return("💩")
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices --json").and_yield(nil, response, nil, nil)

      expect do
        devices = FastlaneCore::Simulator.all
      end.to raise_error("xcrun simctl not working.".red)
    end

    it "properly parses the simctl output and generates Device objects" do
      response = "response"
      expect(response).to receive(:read).and_return(@valid_simulators)
      expect(Open3).to receive(:popen3).with("xcrun simctl list devices --json").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::Simulator.all
      expect(devices.count).to eq(4) # ignore apple tv, watch os and invalid simulators

      expect(devices[0]).to have_attributes(
        name: "iPhone 4s", ios_version: "9.1",
        udid: "81513CB9-9DC7-4D57-80EC-ACAF7E3E2174"
      )
      expect(devices[1]).to have_attributes(
        name: "iPhone 5", ios_version: "9.1",
        udid: "967F93D1-51A8-4BD8-80AE-849CF37EA2B5"
      )
      expect(devices[2]).to have_attributes(
        name: "iPhone 5s", ios_version: "9.1",
        udid: "705E930A-5C0C-4D85-8E01-D39528E64247"
      )
      expect(devices[3]).to have_attributes(
        name: "iPhone 6", ios_version: "9.1",
        udid: "867DB37B-3662-4F7D-BDD5-2E2C3E9F01B0"
      )
    end
  end
end
