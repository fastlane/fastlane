require 'fastlane/documentation/docs_generator'

describe Fastlane do
  describe Fastlane::DocsGenerator do
    it "generates new markdown docs" do
      output_path = "/tmp/documentation.md"
      ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileGrouped')
      Fastlane::DocsGenerator.run(output_path, ff)

      output = File.read(output_path)

      expect(output).to include('sudo gem install fastlane')
      expect(output).to include('# Available Actions')
      expect(output).to include('### test')
      expect(output).to include('# iOS')
      expect(output).to include('fastlane test')
      expect(output).to include('## mac')
      expect(output).to include('----')
      expect(output).to include('Upload something to Google')
      expect(output).to include('fastlane mac beta')
      expect(output).to include('https://fastlane.tools')
      expect(output).to include('https://github.com/')
      expect(output).to include('fastlane docs')
    end
  end
end
