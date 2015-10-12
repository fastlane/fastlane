require 'open3'

describe FastlaneCore do
  describe FastlaneCore::Simulator do
    before do
      @valid_simulators = "Known Devices:
          Felix [A8B765B9-70D4-5B89-AFF5-EDDAF0BC8AAA]
          Felix Krause's iPhone 6 (9.0.1) [2cce6c8deb5ea9a46e19304f4c4e665069ccaaaa]
          iPad 2 (9.0) [863234B6-C857-4DF3-9E27-897DEDF26EDA]
          iPad Air (9.0) [3827540A-D953-49D3-BC52-B66FC59B085E]
          iPad Air 2 (9.0) [6731E2F9-B70A-4102-9B49-6AEFE300F460]
          iPad Retina (9.0) [DFEE2E76-DABF-47C6-AA1A-ACF873E57435]
          iPhone 4s (9.0) [CDEB0462-9ECD-40C7-9916-B7C44EC10E17]
          iPhone 5 (9.0) [1685B071-AFB2-4DC1-BE29-8370BA4A6EBD]
          iPhone 5s (9.0) [C60F3E7A-3D0E-407B-8D0A-EDAF033ED626]
          iPhone 6 (9.0) [4A822E0C-4873-4F12-B798-8B39613B24CE]
          iPhone 6 Plus (9.0) [A522ACFF-7948-4344-8CA8-3F62ED9FFB18]
          iPhone 6s (9.0) [C956F5AA-2EA3-4141-B7D2-C5BE6250A60D]
          iPhone 6s Plus (9.0) [A3754407-21A3-4A80-9559-3170BB3D50FC]
          Known Templates:
          ..."
    end

    it "raises an error if instruments CLI prints garbage" do
      response = "response"
      expect(response).to receive(:read).and_return("💩")
      expect(Open3).to receive(:popen3).with("instruments -s").and_yield(nil, response, nil, nil)

      expect do
        devices = FastlaneCore::Simulator.all
      end.to raise_error("Instruments CLI not working.".red)
    end

    it "properly parses the instruments output and generates Device objects" do
      response = "response"
      expect(response).to receive(:read).and_return(@valid_simulators)
      expect(Open3).to receive(:popen3).with("instruments -s").and_yield(nil, response, nil, nil)

      devices = FastlaneCore::Simulator.all
      expect(devices.count).to eq(11)

      sim = devices.first
      expect(sim.name).to eq('iPad 2')
      expect(sim.udid).to eq('863234B6-C857-4DF3-9E27-897DEDF26EDA')
      expect(sim.ios_version).to eq('9.0')
    end
  end
end
