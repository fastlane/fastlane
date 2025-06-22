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

    describe '#colors_disabled?' do
      it "should return false if no environment variables set" do
        stub_const('ENV', {})
        expect(FastlaneCore::Helper.colors_disabled?).to be(false)
      end
      it "should return true if FASTLANE_DISABLE_COLORS" do
        stub_const('ENV', { "FASTLANE_DISABLE_COLORS" => "true" })
        expect(FastlaneCore::Helper.colors_disabled?).to be(true)
      end
      it "should return true if NO_COLORS" do
        stub_const('ENV', { "NO_COLOR" => 1 })
        expect(FastlaneCore::Helper.colors_disabled?).to be(true)
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

      it "returns true when building in CircleCI" do
        stub_const('ENV', { 'CIRCLECI' => true })
        expect(FastlaneCore::Helper.ci?).to be(true)
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

      it "returns true when building in GitHub Actions" do
        stub_const('ENV', { 'GITHUB_ACTION' => 'FAKE_ACTION' })
        expect(FastlaneCore::Helper.ci?).to be(true)
        stub_const('ENV', { 'GITHUB_ACTIONS' => 'true' })
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

    describe "#is_circle_ci?" do
      it "returns true when building in CircleCI" do
        stub_const('ENV', { 'CIRCLECI' => true })
        expect(FastlaneCore::Helper.ci?).to be(true)
      end

      it "returns false when not building in a known CI environment" do
        stub_const('ENV', {})
        expect(FastlaneCore::Helper.ci?).to be(false)
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
        unless FastlaneCore::Helper.xcode_at_least?("14")
          expect(FastlaneCore::Helper.transporter_path).to match(%r{/Applications/Xcode.*.app/Contents/Applications/Application Loader.app/Contents/itms/bin/iTMSTransporter|/Applications/Xcode.*.app/Contents/SharedFrameworks/ContentDeliveryServices.framework/Versions/A/itms/bin/iTMSTransporter})
        end
      end

      it "#xcode_version", requires_xcode: true do
        expect(FastlaneCore::Helper.xcode_version).to match(/^\d[\.\d]+$/)
      end

      context "#user_defined_itms_path?" do
        it "not defined", requires_xcode: true do
          stub_const('ENV', { 'FASTLANE_ITUNES_TRANSPORTER_PATH' => nil })
          expect(FastlaneCore::Helper.user_defined_itms_path?).to be(false)
        end

        it "is defined", requires_xcode: true do
          stub_const('ENV', { 'FASTLANE_ITUNES_TRANSPORTER_PATH' => '/some/path/to/something' })
          expect(FastlaneCore::Helper.user_defined_itms_path?).to be(true)
        end
      end

      context "#user_defined_itms_path" do
        it "not defined", requires_xcode: true do
          stub_const('ENV', { 'FASTLANE_ITUNES_TRANSPORTER_PATH' => nil })
          expect(FastlaneCore::Helper.user_defined_itms_path).to be(nil)
        end

        it "is defined", requires_xcode: true do
          stub_const('ENV', { 'FASTLANE_ITUNES_TRANSPORTER_PATH' => '/some/path/to/something' })
          expect(FastlaneCore::Helper.user_defined_itms_path).to eq('/some/path/to/something')
        end
      end

      context "#itms_path" do
        it "default", requires_xcode: true do
          stub_const('ENV', { 'FASTLANE_ITUNES_TRANSPORTER_PATH' => nil })

          if FastlaneCore::Helper.xcode_at_least?("14")
            expect(FastlaneCore::UI).to receive(:user_error!).with(/Could not find transporter/)
            expect { FastlaneCore::Helper.itms_path }.not_to raise_error
          else
            expect(FastlaneCore::Helper.itms_path).to match(/itms/)
          end
        end

        it "uses FASTLANE_ITUNES_TRANSPORTER_PATH", requires_xcode: true do
          stub_const('ENV', { 'FASTLANE_ITUNES_TRANSPORTER_PATH' => '/some/path/to/something' })
          expect(FastlaneCore::Helper.itms_path).to eq('/some/path/to/something')
        end
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

    describe "#fastlane_enabled?" do
      it "returns false when FastlaneCore::FastlaneFolder.path is nil" do
        expect(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        expect(FastlaneCore::Helper.fastlane_enabled?).to be(false)
      end

      it "returns true when FastlaneCore::FastlaneFolder.path is not nil" do
        expect(FastlaneCore::FastlaneFolder).to receive(:path).and_return('./fastlane')
        expect(FastlaneCore::Helper.fastlane_enabled?).to be(true)
      end
    end
  end
end
