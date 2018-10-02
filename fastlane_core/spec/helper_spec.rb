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

      it "returns true when building in AppCenter" do
        stub_const('ENV', { 'APPCENTER_BUILD_ID' => '185' })
        expect(FastlaneCore::Helper.ci?).to be(true)
      end

      it "returns true when building in Xcode Server" do
        stub_const('ENV', { 'XCS' => true })
        expect(FastlaneCore::Helper.ci?).to be(true)
      end

      it "returns true when building in Azure DevOps (VSTS) " do
        stub_const('ENV', { 'TF_BUILD' => true })
        expect(FastlaneCore::Helper.ci?).to be(true)
      end
    end
    describe "#fs_is_insensitive? - caches" do
      before(:each) do
        # be sure to not hit cached value
        FastlaneCore::Helper.instance_variable_set(:@fs_sensitivity_cache, nil)
      end
      it "caches the test for insensitive file system" do
        expect(FastlaneCore::Helper.instance_variable_get(:@fs_sensitivity_cache)).to be nil
        expect(File).to receive(:exist?).and_return(true)
        expect(FastlaneCore::Helper.fs_is_insensitive?).to be true
        expect(FastlaneCore::Helper.instance_variable_get(:@fs_sensitivity_cache)).to be true
      end
      it "returns cached value" do
        FastlaneCore::Helper.instance_variable_set(:@fs_sensitivity_cache, "fastlane")
        expect(FastlaneCore::Helper.fs_is_insensitive?).to eq "fastlane"
      end
    end
    describe "#fs_is_insensitive?" do
      context 'when the file system is insensitive' do
        before(:each) do
          # be sure to not hit cached value
          FastlaneCore::Helper.instance_variable_set(:@fs_sensitivity_cache, nil)
          expect(File).to receive(:exist?).and_return(true)
        end
        it "fs is insensitive" do
          expect(FastlaneCore::Helper.fs_is_insensitive?).to be true
        end
      end
      context 'when the file system is sensitive' do
        before(:each) do
          # be sure to not hit cached value
          FastlaneCore::Helper.instance_variable_set(:@fs_sensitivity_cache, nil)
          expect(File).to receive(:exist?).and_return(false)
        end
        it "fs is sensitive" do
          expect(FastlaneCore::Helper.fs_is_insensitive?).to be false
        end
      end
    end

    describe "#compare_paths?" do
      context 'when the file system is insentive' do
        before(:each) do
          allow(FastlaneCore::Helper).to receive(:fs_is_insensitive?) { true }
        end
        it 'ignores case while comparing' do
          expect(FastlaneCore::Helper.compare_paths("FASTLANE", "fastlane")).to be true
        end
        it 'matches equal strings' do
          expect(FastlaneCore::Helper.compare_paths("fastlane", "fastlane")).to be true
        end
      end
      context 'when the file system is sensitive' do
        before(:each) do
          allow(FastlaneCore::Helper).to receive(:fs_is_insensitive?) { false }
        end
        it 'respects case while comparing' do
          expect(FastlaneCore::Helper.compare_paths("FASTLANE", "fastlane")).to be false
        end
        it 'matches equal strings' do
          expect(FastlaneCore::Helper.compare_paths("fastlane", "fastlane")).to be true
        end
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
      let(:directory) { File.absolute_path('/tmp/directory') }
      let(:directory_to_zip) { File.absolute_path('/tmp/directory/to_zip') }
      let(:the_zip) { File.absolute_path('/tmp/thezip.zip') }

      it "creates correct zip command with contents_only set to false with default print option (true)" do
        expect(FastlaneCore::Helper).to receive(:backticks)
          .with("cd '#{directory}' && zip -r '#{the_zip}' 'to_zip'", print: true)
          .exactly(1).times

        FastlaneCore::Helper.zip_directory(directory_to_zip, the_zip, contents_only: false)
      end

      it "creates correct zip command with contents_only set to true with print set to false" do
        expect(FastlaneCore::Helper).to receive(:backticks)
          .with("cd '#{directory_to_zip}' && zip -r '#{the_zip}' *", print: false)
          .exactly(1).times
        expect(FastlaneCore::UI).to receive(:command).exactly(1).times

        FastlaneCore::Helper.zip_directory(directory_to_zip, the_zip, contents_only: true, print: false)
      end
    end
  end
end
