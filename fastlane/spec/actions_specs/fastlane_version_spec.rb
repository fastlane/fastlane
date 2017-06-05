describe Fastlane do
  describe Fastlane::FastFile do
    describe "fastlane_version action" do
      it "works as expected" do
        Fastlane::FastFile.new.parse("lane :test do
          fastlane_version '0.1'
        end").runner.execute(:test)
      end

      it "works as expected with options" do
        allow(FastlaneCore::Changelog).to receive(:show_changes).with("fastlane", '0.1')
        stub_const('Fastlane::VERSION', '0.1')
        Fastlane::FastFile.new.parse("lane :test do
          fastlane_version '0.1', lock: true
        end").runner.execute(:test)
      end

      it "raises an exception if it's an old version" do
        expect do
          expect(FastlaneCore::Changelog).to receive(:show_changes).with("fastlane", Fastlane::VERSION)
          Fastlane::FastFile.new.parse("lane :test do
            fastlane_version '9999'
          end").runner.execute(:test)
        end.to raise_error(/The Fastfile requires a fastlane version of >= 9999./)
      end

      it "raises an exception if it's not an exact version" do
        expect do
          expect(FastlaneCore::Changelog).to receive(:show_changes).with("fastlane", Fastlane::VERSION)
          Fastlane::FastFile.new.parse("lane :test do
            fastlane_version '9999', lock: true
          end").runner.execute(:test)
        end.to raise_error(/The Fastfile requires a fastlane version of 9999./)
      end

      it "raises an exception if it's an old version in a non-bundler environement" do
        expect do
          # We have to clean ENV to be sure that Bundler environement is not defined.
          stub_const('ENV', {})
          expect(FastlaneCore::Changelog).to receive(:show_changes).with("fastlane", Fastlane::VERSION)

          Fastlane::FastFile.new.parse("lane :test do
            fastlane_version '9999'
          end").runner.execute(:test)
        end.to raise_error("The Fastfile requires a fastlane version of >= 9999. You are on #{Fastlane::VERSION}.")
      end

      it "raises an exception if it's an old version in a bundler environement" do
        expect do
          expect(FastlaneCore::Changelog).to receive(:show_changes).with("fastlane", Fastlane::VERSION)

          # Let's define BUNDLE_BIN_PATH in ENV to simulate a bundler environement
          stub_const('ENV', { 'BUNDLE_BIN_PATH' => '/fake/elsewhere' })
          Fastlane::FastFile.new.parse("lane :test do
            fastlane_version '9999'
          end").runner.execute(:test)
        end.to raise_error("The Fastfile requires a fastlane version of >= 9999. You are on #{Fastlane::VERSION}.")
      end

      it "raises an error if no team ID is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            fastlane_version
          end").runner.execute(:test)
        end.to raise_error("Please pass minimum/required fastlane version as parameter to fastlane_version")
      end
    end
  end
end
