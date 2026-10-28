require "fastlane/environment_printer"
require "fastlane/cli_tools_distributor"

describe Fastlane do
  describe Fastlane::EnvironmentPrinter do
    before do
      stub_request(:get, %r{https://rubygems\.org\/api\/v1\/gems\/.*}).
        to_return(status: 200, body: '{"version": "0.16.2"}', headers: {})
    end

    let(:fastlane_files) { Fastlane::EnvironmentPrinter.print_fastlane_files }
    it "contains the key words" do
      expect(fastlane_files).to include("fastlane files")
      expect(fastlane_files).to include("Fastfile")
      expect(fastlane_files).to include("Appfile")
    end

    context "with a Fastfile and an Appfile" do
      let(:fastfile) do
        file = Tempfile.new("Fastfile")
        file.write("lane :beta do\n  api_token('super-secret-token')\nend\n")
        file.close
        file
      end

      let(:appfile) do
        file = Tempfile.new("Appfile")
        file.write("apple_id('secret@example.org')\n")
        file.close
        file
      end

      before do
        allow(FastlaneCore::FastlaneFolder).to receive(:fastfile_path).and_return(fastfile.path)
        allow(CredentialsManager::AppfileConfig).to receive(:default_path).and_return(appfile.path)
      end

      after do
        fastfile.unlink
        appfile.unlink
      end

      it "names them without including their contents" do
        expect(fastlane_files).to include(fastfile.path)
        expect(fastlane_files).to include(appfile.path)
        expect(fastlane_files).not_to(include("super-secret-token"))
        expect(fastlane_files).not_to(include("secret@example.org"))
      end
    end

    let(:env) { Fastlane::EnvironmentPrinter.get }

    it "contains the key words" do
      expect(env).to include("fastlane gems")
      expect(env).to include("generated on")
    end

    it "prints out the loaded fastlane plugins" do
      expect(env).to include("Loaded fastlane plugins")
    end

    it "prints out the loaded gem dependencies" do
      expect(env).to include("Loaded gems")
      expect(env).to include("addressable")
      expect(env).to include("xcpretty")
    end

    it "contains main information about the stack", requires_xcode: true do
      expect(env).to include("Bundler?")
      expect(env).to include("Xcode Path")
      expect(env).to include("Xcode Version")
      expect(env).to include("OpenSSL")
    end

    it "anonymizes a path containing the user’s home" do
      expect(Fastlane::EnvironmentPrinter.anonymized_path('/Users/john/.fastlane/bin/bundle/bin/fastlane', '/Users/john')).to eq('~/.fastlane/bin/bundle/bin/fastlane')
      expect(Fastlane::EnvironmentPrinter.anonymized_path('/Users/john', '/Users/john')).to eq('~')
      expect(Fastlane::EnvironmentPrinter.anonymized_path('/Users/john/', '/Users/john')).to eq('~/')
      expect(Fastlane::EnvironmentPrinter.anonymized_path('/workspace/project/test', '/work')).to eq('/workspace/project/test')
    end

    context 'FastlaneCore::Helper.xcode_version cannot be obtained' do
      before do
        allow(FastlaneCore::Helper).to receive(:xcode_version).and_raise("Boom!")
      end

      it 'contains stack information other than Xcode Version', requires_xcode: true do
        expect(env).to include("Bundler?")
        expect(env).to include("Xcode Path")
        expect(env).not_to(include("Xcode Version"))
        expect(env).to include("OpenSSL")
      end
    end
  end
end
