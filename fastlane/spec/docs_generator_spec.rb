require 'fastlane/documentation/docs_generator'

describe Fastlane do
  describe Fastlane::DocsGenerator do
    it "generates new markdown docs" do
      output_path = "/tmp/documentation.md"
      ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfileGrouped')
      Fastlane::DocsGenerator.run(ff, output_path)

      output = File.read(output_path)

      expect(output).to include('gem install fastlane')
      expect(output).to include('# Available Actions')
      expect(output).to include('### test')
      expect(output).to include('# iOS')
      expect(output).to include('fastlane test')
      expect(output).to include('## mac')
      expect(output).to include('----')
      expect(output).to include('Upload something to Google')
      expect(output).to include('fastlane mac beta')
      expect(output).to include('https://fastlane.tools')
    end

    it "generates new markdown docs but skips empty platforms" do
      output_path = "/tmp/documentation.md"
      ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfilePlatformDocumentation')
      Fastlane::DocsGenerator.run(ff, output_path)

      output = File.read(output_path)

      expect(output).to include('gem install fastlane')
      expect(output).to include('# Available Actions')
      expect(output).to include('## Android')
      expect(output).to include('### android lane')
      expect(output).to include('fastlane android lane')
      expect(output).to include("I'm a lane")

      expect(output).not_to(include('## iOS'))
      expect(output).not_to(include('## Mac'))
      expect(output).not_to(include('mac_lane'))
      expect(output).not_to(include("I'm a mac private_lane"))
    end
  end
end
