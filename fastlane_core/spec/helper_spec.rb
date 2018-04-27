describe FastlaneCore do
  describe FastlaneCore::Helper do
    describe "#bundler?" do
      it "returns false when not in a bundler environment" do
        stub_const('ENV', {})
        expect(FastlaneCore::Helper.bundler?).to be(false)
      end

      it "returns true BUNDLE_BIN_PATH is defined" do
        stub_const('ENV', { 'BUNDLE_BIN_PATH' => '/fake/elsewhere' })
        expect(FastlaneCore::Helper.bundler?).to be(true)
      end

      it "returns true BUNDLE_GEMFILE is defined" do
        stub_const('ENV', { 'BUNDLE_GEMFILE' => '/fake/elsewhere/myFile' })
        expect(FastlaneCore::Helper.bundler?).to be(true)
      end
    end

    describe '#json_file?' do
      it "should return false on invalid json file" do
        expect(FastlaneCore::Helper.json_file?("./fastlane_core/spec/fixtures/json_file/broken")).to be(false)
      end
      it "should return true on valid json file" do
        expect(FastlaneCore::Helper.json_file?("./fastlane_core/spec/fixtures/json_file/valid")).to be(true)
      end
    end

    describe "#ci?" do
      it "returns false when not building in a known CI environment" do
        stub_const('ENV', {})
        expect(FastlaneCore::Helper.ci?).to be(false)
      end

      it "returns true when building in Jenkins" do
        stub_const('ENV', { 'JENKINS_URL' => 'http://fake.jenkins.url' })
        expect(FastlaneCore::Helper.ci?).to be(true)
      end

      it "returns true when building in Jenkins Slave" do
        stub_const('ENV', { 'JENKINS_HOME' => '/fake/jenkins/home' })
        expect(FastlaneCore::Helper.ci?).to be(true)
      end

      it "returns true when building in Travis CI" do
        stub_const('ENV', { 'TRAVIS' => true })
        expect(FastlaneCore::Helper.ci?).to be(true)
      end

      it "returns true when building in gitlab-ci" do
        stub_const('ENV', { 'GITLAB_CI' => true })
        expect(FastlaneCore::Helper.ci?).to be(true)
      end

      it "returns true when building in Xcode Server" do
        stub_const('ENV', { 'XCS' => true })
        expect(FastlaneCore::Helper.ci?).to be(true)
      end
    end

    describe "#keychain_path" do
      it "finds file in current directory" do
        allow(File).to receive(:file?).and_return(false)

        found = File.expand_path("test.keychain")
        allow(File).to receive(:file?).with(found).and_return(true)

        expect(FastlaneCore::Helper.keychain_path("test.keychain")).to eq(File.expand_path(found))
      end

      it "finds file in current directory with -db" do
        allow(File).to receive(:file?).and_return(false)

        found = File.expand_path("test-db")
        allow(File).to receive(:file?).with(found).and_return(true)

        expect(FastlaneCore::Helper.keychain_path("test.keychain")).to eq(File.expand_path(found))
      end

      it "finds file in current directory with spaces and \"" do
        allow(File).to receive(:file?).and_return(false)

        found = File.expand_path('\\"\\ test\\ \\".keychain')
        allow(File).to receive(:file?).with(found).and_return(true)

        expect(FastlaneCore::Helper.keychain_path('\\"\\ test\\ \\".keychain')).to eq(File.expand_path(found))
      end
    end

    describe "Xcode" do
      # Those tests also work when using a beta version of Xcode
      it "#xcode_path", requires_xcode: true do
        expect(FastlaneCore::Helper.xcode_path[-1]).to eq('/')
        expect(FastlaneCore::Helper.xcode_path).to match(%r{/Applications/Xcode.*.app/Contents/Developer/})
      end

      it "#transporter_path", requires_xcode: true do
        expect(FastlaneCore::Helper.transporter_path).to match(%r{/Applications/Xcode.*.app/Contents/Applications/Application Loader.app/Contents/itms/bin/iTMSTransporter})
      end

      it "#xcode_version", requires_xcode: true do
        expect(FastlaneCore::Helper.xcode_version).to match(/^\d[\.\d]+$/)
      end
    end

    describe "#zip_directory" do
      it "creates correct zip command with contents_only set to false with default print option (true)" do
        expect(FastlaneCore::Helper).to receive(:backticks)
          .with("cd '/tmp/directory' && zip -r '/tmp/thezip.zip' 'to_zip'", print: true)
          .exactly(1).times

        FastlaneCore::Helper.zip_directory('/tmp/directory/to_zip', '/tmp/thezip.zip', contents_only: false)
      end

      it "creates correct zip command with contents_only set to true with print set to false" do
        expect(FastlaneCore::Helper).to receive(:backticks)
          .with("cd '/tmp/directory/to_zip' && zip -r '/tmp/thezip.zip' *", print: false)
          .exactly(1).times
        expect(FastlaneCore::UI).to receive(:command).exactly(1).times

        FastlaneCore::Helper.zip_directory('/tmp/directory/to_zip', '/tmp/thezip.zip', contents_only: true, print: false)
      end
    end
  end
end
