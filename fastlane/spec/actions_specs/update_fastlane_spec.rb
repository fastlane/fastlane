describe Fastlane do
  describe Fastlane::FastFile do
    describe "update_fastlane" do
      let(:mock_updater) { double("mock_updater") }
      let(:mock_cleanup) { double("mock_cleanup") }
      let(:mock_instance) do
        {
          update: mock_updater,
          cleanup: mock_cleanup
        }
      end

      it "when no update needed" do
        expect(Gem::CommandManager).to receive(:instance).and_return(mock_instance).twice

        expect(UI).to receive(:success).with("Driving the lane 'test' 🚀")
        expect(UI).to receive(:message).with("Looking for updates for fastlane...")
        expect(UI).to receive(:success).with("Nothing to update ✅")

        expect(mock_updater).to receive(:highest_installed_gems).and_return({})
        expect(mock_updater).to receive(:which_to_update).and_return({})

        result = Fastlane::FastFile.new.parse("lane :test do
          update_fastlane
        end").runner.execute(:test)
      end

      it "when update with RubyGems" do
        expect(Gem::CommandManager).to receive(:instance).and_return(mock_instance).twice

        # Manifest
        expect(FastlaneCore::FastlaneFolder).to receive(:swift?).and_return(true)
        expect(UI).to receive(:success).with(%r{fastlane\/swift\/upgrade_manifest.json})

        # Start
        expect(UI).to receive(:success).with("Driving the lane 'test' 🚀")
        expect(UI).to receive(:message).with("Looking for updates for fastlane...")

        # Find outdated version
        expect(mock_updater).to receive(:highest_installed_gems).and_return({
          "fastlane" => Gem::Specification.new do |s|
            s.name        = 'fastlane'
            s.version     = '2.143.0'
          end
        })
        expect(mock_updater).to receive(:which_to_update).and_return([["fastlane", "2.143.0"]])

        # Fetch latest version and update
        expect(FastlaneCore::UpdateChecker).to receive(:fetch_latest).and_return("2.165.0")
        expect(UI).to receive(:message).with(/Updating fastlane from/)
        expect(mock_updater).to receive(:update_gem)
        expect(UI).to receive(:success).with("Finished updating fastlane")

        # Clean
        expect(UI).to receive(:message).with("Cleaning up old versions...")
        expect(mock_cleanup).to receive(:options).and_return({})
        expect(mock_cleanup).to receive(:execute)

        # Restart process
        expect(UI).to receive(:message).with("fastlane.tools successfully updated! I will now restart myself... 😴")
        expect(Fastlane::Actions::UpdateFastlaneAction).to receive(:exec)

        result = Fastlane::FastFile.new.parse("lane :test do
          update_fastlane
        end").runner.execute(:test)
      end

      it "when update with Homebrew" do
        expect(Fastlane::Helper).to receive(:homebrew?).and_return(true).twice
        expect(Gem::CommandManager).to receive(:instance).and_return(mock_instance).twice

        # Manifest
        expect(FastlaneCore::FastlaneFolder).to receive(:swift?).and_return(true)
        expect(UI).to receive(:success).with(%r{fastlane\/swift\/upgrade_manifest.json})

        # Start
        expect(UI).to receive(:success).with("Driving the lane 'test' 🚀")
        expect(UI).to receive(:message).with("Looking for updates for fastlane...")

        # Find outdated version
        expect(mock_updater).to receive(:highest_installed_gems).and_return({
          "fastlane" => Gem::Specification.new do |s|
            s.name        = 'fastlane'
            s.version     = '2.143.0'
          end
        })
        expect(mock_updater).to receive(:which_to_update).and_return([["fastlane", "2.143.0"]])

        # Fetch latest version and update
        expect(FastlaneCore::UpdateChecker).to receive(:fetch_latest).and_return("2.165.0")
        expect(UI).to receive(:message).with(/Updating fastlane from/)
        expect(Fastlane::Helper).to receive(:backticks).with("brew upgrade fastlane")
        expect(UI).to receive(:success).with("Finished updating fastlane")

        # Restart process
        expect(UI).to receive(:message).with("fastlane.tools successfully updated! I will now restart myself... 😴")
        expect(Fastlane::Actions::UpdateFastlaneAction).to receive(:exec)

        result = Fastlane::FastFile.new.parse("lane :test do
          update_fastlane
        end").runner.execute(:test)
      end

      describe "#get_gem_name" do
        it "with RubyGems < 3.1" do
          require 'rubygems'
          tool_info = ["fastlane", Gem::Version.new("1.2.3")]
          name = Fastlane::Actions::UpdateFastlaneAction.get_gem_name(tool_info)
          expect(name).to eq("fastlane")
        end

        it "with RubyGems >= 3.1" do
          tool_info = OpenStruct.new
          tool_info.name = "fastlane"
          tool_info.version = "1.2.3"

          name = Fastlane::Actions::UpdateFastlaneAction.get_gem_name(tool_info)
          expect(name).to eq("fastlane")
        end

        it "with unsupported RubyGems" do
          expect do
            tool_info = OpenStruct.new
            Fastlane::Actions::UpdateFastlaneAction.get_gem_name(tool_info)
          end.to raise_error(FastlaneCore::Interface::FastlaneCrash, /Unknown gem update information returned from RubyGems. Please file a new issue for this/)
        end
      end
    end
  end
end
