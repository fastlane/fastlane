require 'fastlane/documentation/docs_generator'
require 'tempfile'

describe Fastlane do
  describe Fastlane::DocsGenerator do
    it "generates new markdown docs" do
      ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfileGrouped')

      output = Tempfile.open(['documentation', '.md']) do |output_file|
        Fastlane::DocsGenerator.run(ff, output_file.path)
        output_file.read
      end

      expect(output).to include('installation instructions')
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
      ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfilePlatformDocumentation')

      output = Tempfile.open(['documentation', '.md']) do |output_file|
        Fastlane::DocsGenerator.run(ff, output_file.path)
        output_file.read
      end

      expect(output).to include('installation instructions')
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

    it "produces no diff on any platform with default Git SCM settings" do
      FastlaneSpec::Env.with_env_values('FASTLANE_SKIP_DOCS' => 'false') do
        Dir.chdir('fastlane/spec/fixtures/docs') do
          # Run a lane, which will trigger fastlane docs generation, and then
          # verify that no changes are made in that subtree.
          Fastlane::FastFile.new('Fastfile').runner.execute(:ensure_git_status_clean)
        end
      end
    end
  end
end
