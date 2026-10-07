describe Gym do
  # Unset every option these examples rely on being unset, and both switches for the lookup guard,
  # so the developer's environment can't change the outcome
  around do |example|
    FastlaneSpec::Env.with_env_values(
      "FASTLANE_DISALLOW_XCODEBUILD_SETTINGS_LOOKUP" => nil,
      "GYM_DISALLOW_XCODEBUILD_SETTINGS_LOOKUP" => nil,
      "GYM_DESTINATION" => nil,
      "GYM_SDK" => nil,
      "GYM_CATALYST_PLATFORM" => nil,
      "GYM_SCHEME" => nil,
      "GYM_CONFIGURATION" => nil,
      "GYM_EXPORT_METHOD" => nil,
      "GYM_EXPORT_TEAM_ID" => nil,
      "GYM_INSTALLER_CERT_NAME" => nil,
      "GYM_APP_NAME" => nil,
      "GYM_OUTPUT_NAME" => nil,
      "GYM_SKIP_ARCHIVE" => nil,
      "GYM_SKIP_PROFILE_DETECTION" => nil,
      "GYM_USE_GENERIC_ARCHIVE_FIX" => nil
    ) { example.run }
  end

  # A project double with nothing stubbed fails the example if it is asked anything,
  # which is how these examples check that no build settings were read
  let(:project) { instance_double(FastlaneCore::Project) }

  def stub_config(options)
    allow(Gym).to receive(:config).and_return(FastlaneCore::Configuration.create(Gym::Options.available_options, options))
    allow(Gym).to receive(:project).and_return(project)
  end

  describe "platform checks" do
    [
      { destination: "generic/platform=iOS", sdk: "iphoneos", catalyst_platform: "ios" }, # the options from #30365
      { destination: "generic/platform=iOS" },
      { destination: "generic/platform=ios" },
      { destination: "platform=iOS Simulator,id=00000000-0000-0000-0000-000000000000" },
      { destination: "generic/platform=tvOS" },
      { destination: "generic/platform=watchOS" },
      { destination: "generic/platform=visionOS" },
      { destination: "generic/platform=xrOS" }
    ].each do |options|
      it "know #{options} is not a macOS build without reading build settings" do
        stub_config(options)

        expect(Gym.building_for_mac?).to eq(false)
        expect(Gym.building_for_pkg?).to eq(false)
        expect(Gym.building_for_ipa?).to eq(true)
        expect(Gym.building_for_ios?).to eq(true)
      end
    end

    [
      { destination: "generic/platform=macOS" },
      # xcodebuild matches the platform name without regard to case, so these are macOS too
      { destination: "generic/platform=macos" },
      { destination: "generic/platform=MACOS" },
      { destination: "generic/platform=macosx" },
      { destination: "platform=macOS,variant=Mac Catalyst" },
      { destination: "id=00000000-0000-0000-0000-000000000000" },
      { destination: "generic/platform=iOS", sdk: "macosx" },
      { destination: "generic/platform=iOS", catalyst_platform: "macos" }, # what build_mac_app sets
      {}
    ].each do |options|
      it "read the project's build settings for #{options}" do
        stub_config(options)
        allow(project).to receive_messages(supports_mac_catalyst?: false, multiplatform?: false, mac?: true)

        expect(Gym.building_for_pkg?).to eq(true)
      end
    end
  end

  describe "Mac Catalyst checks" do
    [
      [{ catalyst_platform: "ios" }, :building_mac_catalyst_for_mac?],
      [{ sdk: "iphoneos" }, :building_mac_catalyst_for_mac?],
      [{}, :building_mac_catalyst_for_mac?],
      [{ catalyst_platform: "macos" }, :building_mac_catalyst_for_ios?],
      [{ sdk: "macosx" }, :building_mac_catalyst_for_ios?],
      [{}, :building_mac_catalyst_for_ios?]
    ].each do |options, check|
      it "#{check} is false for #{options} without asking whether the project supports Mac Catalyst" do
        stub_config(options)

        expect(Gym.public_send(check)).to eq(false)
      end
    end

    [
      [{ catalyst_platform: "macos" }, :building_mac_catalyst_for_mac?],
      [{ sdk: "macosx" }, :building_mac_catalyst_for_mac?],
      [{ catalyst_platform: "ios" }, :building_mac_catalyst_for_ios?],
      [{ sdk: "iphoneos" }, :building_mac_catalyst_for_ios?]
    ].each do |options, check|
      it "#{check} follows the project for #{options}" do
        stub_config(options)

        allow(project).to receive(:supports_mac_catalyst?).and_return(true)
        expect(Gym.public_send(check)).to eq(true)

        allow(project).to receive(:supports_mac_catalyst?).and_return(false)
        expect(Gym.public_send(check)).to eq(false)
      end
    end
  end

  describe "setup with build setting lookups disallowed" do
    let(:options) do
      {
        project: "./gym/examples/standard/Example.xcodeproj",
        scheme: "Example",
        configuration: "Release",
        export_method: "ad-hoc",
        output_name: "App",
        destination: "generic/platform=iOS",
        disallow_xcodebuild_settings_lookup: true
      }
    end

    before do
      expect(FastlaneCore::Project).not_to receive(:run_command)
    end

    def configure(options)
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
    end

    it "needs no build settings when the destination names the platform" do
      # The provisioning profile mapping used to fail on a Mac Catalyst lookup and report it with UI.error
      expect(FastlaneCore::UI).not_to receive(:error)

      configure(options)

      expect(Gym.building_for_ipa?).to eq(true)
    end

    it "names `destination` when the platform would have to be detected" do
      expect do
        configure(options.except(:destination))
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /To fix this, set the `destination` option/)
    end

    it "names `output_name` when the output name would have to be detected" do
      expect do
        configure(options.except(:output_name))
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /To fix this, set the `output_name` option/)
    end

    it "fails before the archive is built when it would have to export for macOS" do
      expect do
        configure(options.merge(destination: "generic/platform=macOS"))
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /can only export an iOS, tvOS, watchOS or visionOS build/)
    end

    it "lets a macOS build through when nothing will be exported" do
      configure(options.merge(destination: "generic/platform=macOS", skip_archive: true))

      expect(Gym.config[:destination]).to eq("generic/platform=macOS")
    end

    it "doesn't look for an installer certificate, which only signs macOS exports" do
      expect(FastlaneCore::Helper).not_to receive(:backticks)

      configure(options.merge(export_method: "app-store"))

      expect(Gym.config[:installer_cert_name]).to be_nil
    end
  end

  describe "the build configuration for the provisioning profile mapping" do
    it "names `configuration` when it would have to be read from the build settings" do
      stub_config({})
      real_project = FastlaneCore::Project.new(project: "./gym/examples/standard/Example.xcodeproj", disallow_xcodebuild_settings_lookup: true)
      expect(FastlaneCore::Project).not_to receive(:run_command)

      expect do
        Gym::CodeSigningMapping.new(project: real_project).detect_configuration_for_archive
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /To fix this, set the `configuration` option/)
    end
  end

  describe "the build log path" do
    def log_name(options, disallowed_by:)
      stub_config(options.merge(scheme: "Example", buildlog_path: Dir.mktmpdir))
      allow(project).to receive(:xcodebuild_settings_lookup_disallowed_by).and_return(disallowed_by)
      File.basename(Gym::BuildCommandGenerator.xcodebuild_log_path)
    end

    context "when build settings can't be read" do
      it "uses `app_name` alone" do
        expect(log_name({ app_name: "CustomApp" }, disallowed_by: "the option")).to eq("CustomApp-Example.log")
      end

      it "uses `output_name` alone instead of reading the app name" do
        expect(log_name({ output_name: "App" }, disallowed_by: "the option")).to eq("App-Example.log")
      end

      it "prefers `app_name` to `output_name`" do
        expect(log_name({ app_name: "CustomApp", output_name: "App" }, disallowed_by: "the option")).to eq("CustomApp-Example.log")
      end
    end

    context "when build settings can be read" do
      it "uses the project's app name when `app_name` isn't set, whatever `output_name` is" do
        allow(project).to receive(:app_name).and_return("ExampleProductName")

        expect(log_name({ output_name: "App" }, disallowed_by: nil)).to eq("ExampleProductName-Example.log")
        expect(log_name({}, disallowed_by: nil)).to eq("ExampleProductName-Example.log")
      end
    end
  end

  describe "the generic archive fix" do
    def fix_applied?(options, disallowed_by:)
      stub_config(options)
      allow(project).to receive(:xcodebuild_settings_lookup_disallowed_by).and_return(disallowed_by)
      applied = false
      allow(Gym::XcodebuildFixes).to receive(:generic_archive_fix) { applied = true }
      Gym::Runner.new.send(:fix_generic_archive)
      applied
    end

    it "doesn't ask the project anything unless it is enabled" do
      expect(fix_applied?({ destination: "generic/platform=iOS" }, disallowed_by: nil)).to eq(false)
    end

    context "when enabled" do
      around do |example|
        FastlaneSpec::Env.with_env_values("GYM_USE_GENERIC_ARCHIVE_FIX" => "true") { example.run }
      end

      it "skips watchOS projects" do
        allow(project).to receive(:watchos?).and_return(true)
        expect(fix_applied?({ destination: "generic/platform=iOS" }, disallowed_by: nil)).to eq(false)

        allow(project).to receive(:watchos?).and_return(false)
        expect(fix_applied?({ destination: "generic/platform=iOS" }, disallowed_by: nil)).to eq(true)
      end

      it "goes by the destination when build settings can't be read" do
        expect(fix_applied?({ destination: "generic/platform=watchOS" }, disallowed_by: "the option")).to eq(false)
        expect(fix_applied?({ destination: "generic/platform=iOS" }, disallowed_by: "the option")).to eq(true)
      end
    end
  end

  describe "installerSigningCertificate in the export options" do
    def export_options(options)
      stub_config(options.merge(installer_cert_name: "3rd Party Mac Developer Installer: Team (ABCDE12345)", archive_path: File.join(Dir.mktmpdir, "App.xcarchive")))
      allow(Gym).to receive(:cache).and_return({})

      Gym::PackageCommandGeneratorXcode7.generate
      Plist.parse_xml(Gym::PackageCommandGeneratorXcode7.config_path)
    end

    it "is left out of an IPA export, without reading build settings" do
      expect(export_options(destination: "generic/platform=iOS", export_method: "app-store")).not_to have_key("installerSigningCertificate")
    end

    it "is kept for a macOS package export" do
      allow(project).to receive_messages(supports_mac_catalyst?: false, multiplatform?: false, mac?: true)

      result = export_options(destination: "generic/platform=macOS", export_method: "app-store")
      expect(result["installerSigningCertificate"]).to eq("3rd Party Mac Developer Installer: Team (ABCDE12345)")
    end
  end

  describe Gym::Runner, requires_xcode: true do
    # Runs everything but the external commands: xcodebuild archive and export, and xattr
    def run_gym(options)
      Dir.mktmpdir do |tmp|
        archive_path = File.join(tmp, "App.xcarchive")
        FileUtils.mkdir_p(File.join(archive_path, "Products"))
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options.merge(archive_path: archive_path, output_directory: tmp, buildlog_path: tmp))

        allow(FastlaneCore::CommandExecutor).to receive(:execute).and_return("")
        runner = Gym::Runner.new
        allow(runner).to receive(:system).and_return(true)
        allow(runner).to receive(:move_ipa).and_return(File.join(tmp, "App.ipa"))
        allow(Gym).to receive(:export_destination_upload?).and_return(false)
        runner.run
      end
    end

    it "archives and exports with the options from #30365 without running xcodebuild -showBuildSettings" do
      expect(FastlaneCore::Project).not_to receive(:run_command)

      run_gym(
        project: "./gym/examples/standard/Example.xcodeproj",
        scheme: "Example",
        configuration: "Release",
        export_method: "ad-hoc",
        output_name: "App",
        export_team_id: "ABCDE12345",
        destination: "generic/platform=iOS",
        sdk: "iphoneos",
        catalyst_platform: "ios",
        disallow_xcodebuild_settings_lookup: true
      )
    end
  end
end
