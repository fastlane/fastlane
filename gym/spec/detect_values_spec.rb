describe Gym do
  describe Gym::DetectValues do
    describe 'Xcode config handling', :stuff, requires_xcodebuild: true do
      now = Time.now
      day = now.strftime("%F")

      before do
        # These tests can take some time to run
        # Mocking Time.now to ensure test pass when running between two days
        expect(Time).to receive(:now).and_return(now).once
      end

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

    describe '#detect_third_party_installer', :stuff, requires_xcodebuild: true do
      let(:team_name) { "Some Team Name" }
      let(:team_id) { "123456789" }

      def installer_certs(*names)
        names.map { |name| instance_double(Security::Certificate, name: "3rd Party Mac Developer Installer: #{name}") }
      end

      let(:output_2_matching_1_nonmatching) { installer_certs("Not A Team Name (111222333)", "#{team_name} (#{team_id})", "#{team_name} (#{team_id})") }
      let(:output_1_nonmatching) { installer_certs("Not A Team Name (111222333)") }
      let(:output_none) { [] }

      it "no team id found" do
        allow_any_instance_of(FastlaneCore::Project).to receive(:build_settings).with(anything).and_call_original
        allow_any_instance_of(FastlaneCore::Project).to receive(:build_settings).with(key: "DEVELOPMENT_TEAM").and_return(nil)

        expect(Security::Certificate).to_not(receive(:find))
        options = { project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        installer_cert_name = Gym.config[:installer_cert_name]
        expect(installer_cert_name).to eq(nil)
      end

      describe "using export_team_id" do
        let(:options) { { project: "./gym/examples/multipleSchemes/Example.xcodeproj", export_team_id: team_id, export_method: "app-store" } }

        it "finds installer cert from list with 2 matching and 1 non-matching" do
          expect(Security::Certificate).to receive(:find).with(name: "3rd Party Mac Developer Installer: ").and_return(output_2_matching_1_nonmatching)
          Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

          installer_cert_name = Gym.config[:installer_cert_name]
          expect(installer_cert_name).to eq("3rd Party Mac Developer Installer: #{team_name} (#{team_id})")
        end

        it "does not find installer cert from list with 1 non-matching" do
          expect(Security::Certificate).to receive(:find).with(name: "3rd Party Mac Developer Installer: ").and_return(output_1_nonmatching)
          Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

          installer_cert_name = Gym.config[:installer_cert_name]
          expect(installer_cert_name).to eq(nil)
        end

        it "does not installer cert from empty list" do
          expect(Security::Certificate).to receive(:find).with(name: "3rd Party Mac Developer Installer: ").and_return(output_none)
          Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

          installer_cert_name = Gym.config[:installer_cert_name]
          expect(installer_cert_name).to eq(nil)
        end

        it "reports a failed search and finds no installer cert" do
          expect(Security::Certificate).to receive(:find).with(name: "3rd Party Mac Developer Installer: ").and_raise(Security::Error.new(50, "security: not allowed\n"))
          expect(FastlaneCore::UI).to receive(:error).with("Could not search for installer certificates: security: not allowed (status 50)")
          Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

          installer_cert_name = Gym.config[:installer_cert_name]
          expect(installer_cert_name).to eq(nil)
        end
      end

      describe "using DEVELOPMENT_TEAM builds setting" do
        let(:options) { { project: "./gym/examples/multipleSchemes/Example.xcodeproj", export_method: "app-store" } }

        before do
          allow_any_instance_of(FastlaneCore::Project).to receive(:build_settings).with(anything).and_call_original
          allow_any_instance_of(FastlaneCore::Project).to receive(:build_settings).with(key: "DEVELOPMENT_TEAM").and_return(team_id)
        end

        it "finds installer cert from list with 2 matching and 1 non-matching" do
          expect(Security::Certificate).to receive(:find).with(name: "3rd Party Mac Developer Installer: ").and_return(output_2_matching_1_nonmatching)
          Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

          installer_cert_name = Gym.config[:installer_cert_name]
          expect(installer_cert_name).to eq("3rd Party Mac Developer Installer: #{team_name} (#{team_id})")
        end

        it "does not find installer cert from list with 1 non-matching" do
          expect(Security::Certificate).to receive(:find).with(name: "3rd Party Mac Developer Installer: ").and_return(output_1_nonmatching)
          Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

          installer_cert_name = Gym.config[:installer_cert_name]
          expect(installer_cert_name).to eq(nil)
        end

        it "does not installer cert from empty list" do
          expect(Security::Certificate).to receive(:find).with(name: "3rd Party Mac Developer Installer: ").and_return(output_none)
          Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

          installer_cert_name = Gym.config[:installer_cert_name]
          expect(installer_cert_name).to eq(nil)
        end
      end
    end
  end
end
