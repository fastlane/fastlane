describe Gym do
  describe Gym::DetectValues do
    day = Time.now.strftime("%F")

    describe 'Xcode config handling', :stuff, requires_xcodebuild: true do
      it "fetches the custom build path from the Xcode config" do
        expect(Gym::DetectValues).to receive(:has_xcode_preferences_plist?).and_return(true)
        expect(Gym::DetectValues).to receive(:xcode_preferences_dictionary).and_return({ "IDECustomDistributionArchivesLocation" => "/test/path" })

        options = { project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        path = Gym.config[:build_path]
        expect(path).to eq("/test/path/#{day}")
      end

      it "fetches the default build path from the Xcode config when preference files exists but not archive location defined" do
        expect(Gym::DetectValues).to receive(:has_xcode_preferences_plist?).and_return(true)
        expect(Gym::DetectValues).to receive(:xcode_preferences_dictionary).and_return({})

        options = { project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        archive_path = File.expand_path("~/Library/Developer/Xcode/Archives/#{day}")
        path = Gym.config[:build_path]
        expect(path).to eq(archive_path)
      end

      it "fetches the default build path from the Xcode config when missing Xcode preferences plist" do
        expect(Gym::DetectValues).to receive(:has_xcode_preferences_plist?).and_return(false)

        options = { project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        archive_path = File.expand_path("~/Library/Developer/Xcode/Archives/#{day}")
        path = Gym.config[:build_path]
        expect(path).to eq(archive_path)
      end
    end
  end
end
