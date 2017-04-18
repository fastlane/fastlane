describe Gym do
  describe Gym::DetectValues do
    day = Time.now.strftime("%F")

    describe 'Xcode config handling' do
      it "fetches the custom build path from the Xcode config" do
        options = { xcode_preference_plist_path: "./gym/spec/fixtures/com.apple.dt.Xcode.plist", project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        path = Gym.config[:build_path]
        expect(path).to eq("/test/path/#{day}")
      end

      it "fetches the default build path from the Xcode config" do
        options = { xcode_preference_plist_path: "./gym/spec/fixtures/com.apple.dt.Xcode.empty.plist", project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        archive_path = File.expand_path("~/Library/Developer/Xcode/Archives/#{day}")
        path = Gym.config[:build_path]
        expect(path).to eq(archive_path)
      end

      it "fetches the default build path from the Xcode config when missing Xcode preferences plit" do
        options = { xcode_preference_plist_path: "", project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        archive_path = File.expand_path("~/Library/Developer/Xcode/Archives/#{day}")
        path = Gym.config[:build_path]
        expect(path).to eq(archive_path)
      end
    end
  end
end
