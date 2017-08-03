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

      describe "self.provisioning_profile_specifier_from_xcargs" do
        let(:options) { { project: "./gym/examples/multipleSchemes/Example.xcodeproj" } }
        context "when xcargs is nil" do
          it "return nil" do
            Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

            expect(Gym::DetectValues.provisioning_profile_specifier_from_xcargs).to be nil
          end
        end
        context "when PROVISIONING_PROFILE_SPECIFIER does not exist" do
          it "return nil" do
            options[:xcargs] = 'FOO="BAR"'
            Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

            expect(Gym::DetectValues.provisioning_profile_specifier_from_xcargs).to be nil
          end
        end
        context "when single quote is used" do
          it "return the value of PROVISIONING_PROFILE_SPECIFIER" do
            options[:xcargs] = "PROVISIONING_PROFILE_SPECIFIER='Overwrited Provisioning Name'"
            Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

            expect(Gym::DetectValues.provisioning_profile_specifier_from_xcargs).to eq('Overwrited Provisioning Name')
          end
        end
        context "when double quote is used" do
          it "return the value of PROVISIONING_PROFILE_SPECIFIER" do
            options[:xcargs] = 'PROVISIONING_PROFILE_SPECIFIER="Overwrited Provisioning Name"'
            Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

            expect(Gym::DetectValues.provisioning_profile_specifier_from_xcargs).to eq('Overwrited Provisioning Name')
          end
        end
        context "when double quote is used" do
          it "return the value of PROVISIONING_PROFILE_SPECIFIER" do
            xcargs = { PROVISIONING_PROFILE_SPECIFIER: "Overwrited Provisioning Name" }
            options[:xcargs] = xcargs
            Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

            expect(Gym::DetectValues.provisioning_profile_specifier_from_xcargs).to eq('Overwrited Provisioning Name')
          end
        end
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

        describe "overwrite PROVISIONING_PROFILE_SPECIFIER set in xcargs option" do
          it "overwrite the value correctly" do
            options[:xcargs] = "PROVISIONING_PROFILE_SPECIFIER='Overwrited Provisioning'"
            Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

            Gym::DetectValues.detect_selected_provisioning_profiles
            expect(Gym.config[:export_options][:provisioningProfiles]).to eq({
              "tools.fastlane.debug.app" => "Overwrited Provisioning",
              "tools.fastlane.app" => "Overwrited Provisioning",
              "com.krausefx.ExampleTests" => "Overwrited Provisioning",
              "com.krausefx.ExampleUITests" => "Overwrited Provisioning"
            })
          end
        end
      end
    end
  end
end
