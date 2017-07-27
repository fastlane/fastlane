describe Gym do
  describe Gym::DetectValues do
    day = Time.now.strftime("%F")

    describe 'Xcode config handling', :stuff do
      it "fetches the custom build path from the Xcode config" do
        expect(Gym::DetectValues).to receive(:xcode_preferences_dictionary).and_return({ "IDECustomDistributionArchivesLocation" => "/test/path" })

        options = { project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        path = Gym.config[:build_path]
        expect(path).to eq("/test/path/#{day}")
      end

      it "fetches the default build path from the Xcode config when preference files exists but not archive location defined" do
        expect(Gym::DetectValues).to receive(:xcode_preferences_dictionary).and_return({})

        options = { project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        archive_path = File.expand_path("~/Library/Developer/Xcode/Archives/#{day}")
        path = Gym.config[:build_path]
        expect(path).to eq(archive_path)
      end

      it "fetches the default build path from the Xcode config when missing Xcode preferences plit" do
        expect(Gym::DetectValues).to receive(:xcode_preference_plist_path).and_return(nil)

        options = { project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        archive_path = File.expand_path("~/Library/Developer/Xcode/Archives/#{day}")
        path = Gym.config[:build_path]
        expect(path).to eq(archive_path)
      end

      describe "provisioning profile" do
        let(:configuration) { "Debug" }
        let(:options) do
        {
            workspace: "./gym/examples/cocoapods/Example.xcworkspace",
            export_method: "enterprise",
            scheme: "Example",
            configuration: configuration
        }
        end
        it "fetches the default build path from the Xcode config when missing Xcode preferences plit" do
          Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

          Gym::DetectValues.detect_selected_provisioning_profiles
          expect(Gym.config[:export_options][:provisioningProfiles]).to eq({"tools.fastlane.debug.app" => "Test Provisioning Profile for Debug"})
        end
      end
    end
  end
end
