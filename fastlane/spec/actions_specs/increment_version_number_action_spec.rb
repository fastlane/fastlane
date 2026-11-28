describe Fastlane do
  describe Fastlane::FastFile do
    describe "Increment Version Number Integration" do
      let(:dir) { Dir.mktmpdir }
      let(:info_plist) { File.join(dir, "Info.plist") }

      def increment_version_number(options = "")
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number(#{options})
        end").runner.execute(:test)
      end

      # Creates a project whose Info.plist holds the given version, and returns its path.
      def project_with_version(version)
        create_versioning_project(dir, info_plist: { "CFBundleShortVersionString" => version })
      end

      def info_plist_version
        Xcodeproj::Plist.read_from_path(info_plist)["CFBundleShortVersionString"]
      end

      {
          "1" => "2",
          "1.1" => "1.2",
          "1.1.1" => "1.1.2"
      }.each do |from_version, to_version|
        it "increments all targets' version number from #{from_version} to #{to_version}" do
          project_path = project_with_version(from_version)

          increment_version_number("xcodeproj: '#{project_path}'")

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq(to_version)
          expect(info_plist_version).to eq(to_version)
        end
      end

      ["1.0", "10"].each do |version|
        it "raises an exception when trying to increment patch version number for #{version} (which has no patch number)" do
          project_path = project_with_version(version)

          expect do
            increment_version_number("xcodeproj: '#{project_path}', bump_type: 'patch'")
          end.to raise_error("Can't increment version")
        end
      end

      {
        "1.0.0" => "1.1.0",
        "10.13" => "10.14"
      }.each do |from_version, to_version|
        it "increments all targets' minor version number from #{from_version} to #{to_version}" do
          project_path = project_with_version(from_version)

          increment_version_number("xcodeproj: '#{project_path}', bump_type: 'minor'")

          expect(info_plist_version).to eq(to_version)
        end
      end

      it "raises an exception when trying to increment minor version number for 12 (which has no minor number)" do
        project_path = project_with_version("12")

        expect do
          increment_version_number("xcodeproj: '#{project_path}', bump_type: 'minor'")
        end.to raise_error("Can't increment version")
      end

      {
        "1.0.0" => "2.0.0",
        "10.13" => "11.0",
        "12" => "13"
      }.each do |from_version, to_version|
        it "it increments all targets' major version number from #{from_version} to #{to_version}" do
          project_path = project_with_version(from_version)

          increment_version_number("xcodeproj: '#{project_path}', bump_type: 'major'")

          expect(info_plist_version).to eq(to_version)
        end
      end

      it "uses the only Xcode project in the current directory" do
        project_with_version("1.0.0")

        Dir.chdir(dir) { increment_version_number("bump_type: 'major'") }

        expect(info_plist_version).to eq("2.0.0")
      end

      ["1.4.3", "1.0", "10"].each do |version|
        it "passes a custom version number #{version}" do
          project_path = project_with_version("0.1")

          increment_version_number("xcodeproj: '#{project_path}', version_number: \"#{version}\"")

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq(version)
          expect(info_plist_version).to eq(version)
        end
      end

      it "writes the version number without shell expansion" do
        project_path = project_with_version("0.1")

        increment_version_number("xcodeproj: '#{project_path}', version_number: '1.0$HOME'")

        expect(info_plist_version).to eq("1.0$HOME")
      end

      it "prefers a custom version number over a boring version bump" do
        project_path = project_with_version("0.1")

        result = increment_version_number("xcodeproj: '#{project_path}', version_number: '1.77.3', bump_type: 'major'")

        expect(result).to eq("1.77.3")
      end

      it "automatically removes new lines from the version number" do
        project_path = project_with_version("0.1")

        result = increment_version_number("xcodeproj: '#{project_path}', version_number: '1.77.3\n', bump_type: 'major'")

        expect(result).to eq("1.77.3")
        expect(info_plist_version).to eq("1.77.3")
      end

      it "resolves $(MARKETING_VERSION) from the build settings and keeps it in the Info.plist" do
        project_path = create_versioning_project(dir, build_settings: { "MARKETING_VERSION" => "1.2.3" }, info_plist: { "CFBundleShortVersionString" => "$(MARKETING_VERSION)" })

        result = increment_version_number("xcodeproj: '#{project_path}'")

        expect(result).to eq("1.2.4")
        expect(versioning_project_build_settings(project_path, "MARKETING_VERSION")).to eq(["1.2.4", "1.2.4"])
        expect(info_plist_version).to eq("$(MARKETING_VERSION)")
      end

      it "resolves ${MARKETING_VERSION} using get_version_number action" do
        project_path = project_with_version("${MARKETING_VERSION}")
        expect(Fastlane::Actions::GetVersionNumberAction).to receive(:run)
          .with(xcodeproj: project_path)
          .and_return("1.2.3")
        expect(UI).to receive(:verbose)
          .with("The Info.plist version is ${MARKETING_VERSION}, resolving it...")

        result = increment_version_number("xcodeproj: '#{project_path}'")

        expect(result).to eq("1.2.4")
      end

      it "updates the build setting that the Info.plist refers to" do
        project_path = create_versioning_project(dir, build_settings: { "APP_VERSION" => "1.2.3", "MARKETING_VERSION" => "9.9.9" }, info_plist: { "CFBundleShortVersionString" => "$(APP_VERSION)" })
        expect(Fastlane::Actions::GetVersionNumberAction).to receive(:run).and_return("1.2.3")

        increment_version_number("xcodeproj: '#{project_path}'")

        expect(versioning_project_build_settings(project_path, "APP_VERSION")).to eq(["1.2.4", "1.2.4"])
        expect(versioning_project_build_settings(project_path, "MARKETING_VERSION")).to eq(["9.9.9", "9.9.9"])
      end

      it "updates MARKETING_VERSION build settings when a custom version number is provided" do
        project_path = create_versioning_project(dir, build_settings: { "MARKETING_VERSION" => "1.2.3" })

        result = increment_version_number("xcodeproj: '#{project_path}', version_number: '2.0.0'")

        expect(result).to eq("2.0.0")
        expect(versioning_project_build_settings(project_path, "MARKETING_VERSION")).to eq(["2.0.0", "2.0.0"])
      end

      it "raises an exception when the current directory has no Xcode project and no project is provided" do
        expect do
          Dir.chdir(dir) { increment_version_number("version_number: '2.0.0'") }
        end.to raise_error(/Could not find a single Xcode project/)
      end

      it "raises an exception when multiple root projects exist and no project is provided" do
        FileUtils.mkdir_p(File.join(dir, "App.xcodeproj"))
        FileUtils.mkdir_p(File.join(dir, "Extension.xcodeproj"))

        expect do
          Dir.chdir(dir) { increment_version_number("version_number: '2.0.0'") }
        end.to raise_error(/Could not find a single Xcode project/)
      end

      describe ".update_project_version" do
        let(:build_configuration) { Struct.new(:build_settings) }

        it "updates MARKETING_VERSION build settings when the version is stored in the Xcode project" do
          project_config = build_configuration.new({ "MARKETING_VERSION" => "1.0.0" })
          target_config = build_configuration.new({ "MARKETING_VERSION" => "1.0.0" })
          other_config = build_configuration.new({ "CURRENT_PROJECT_VERSION" => "42" })
          target = double("target", build_configurations: [target_config, other_config])
          # The project has no project.pbxproj file on disk, so the xcodeproj gem saves it.
          project = double("project", build_configurations: [project_config], targets: [target], project_dir: Pathname.new(dir), path: File.join(dir, "Project.xcodeproj"))
          expect(project).to receive(:save)

          Fastlane::Actions::IncrementVersionNumberAction.update_project_version(project, "MARKETING_VERSION", "1.2.3")

          expect(project_config.build_settings["MARKETING_VERSION"]).to eq("1.2.3")
          expect(target_config.build_settings["MARKETING_VERSION"]).to eq("1.2.3")
          expect(other_config.build_settings["CURRENT_PROJECT_VERSION"]).to eq("42")
        end

        it "does not save the Xcode project when MARKETING_VERSION is not set" do
          project_config = build_configuration.new({ "CURRENT_PROJECT_VERSION" => "42" })
          target_config = build_configuration.new({ "PRODUCT_BUNDLE_IDENTIFIER" => "tools.fastlane.example" })
          target = double("target", build_configurations: [target_config])
          project = double("project", build_configurations: [project_config], targets: [target], project_dir: Pathname.new(dir))
          expect(project).not_to receive(:save)

          Fastlane::Actions::IncrementVersionNumberAction.update_project_version(project, "MARKETING_VERSION", "1.2.3")

          expect(project_config.build_settings["CURRENT_PROJECT_VERSION"]).to eq("42")
          expect(target_config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"]).to eq("tools.fastlane.example")
        end

        it "does not save the Xcode project when only an xcconfig changed" do
          project = double("project")
          expect(Fastlane::Helper::XcodeprojHelper).to receive(:update_info_plist_value)
          expect(Fastlane::Helper::XcodeprojHelper).to receive(:update_project_build_setting)
            .with(project, "MARKETING_VERSION", "1.2.3")
            .and_return(project: false, xcconfig: true)
          expect(project).not_to receive(:save)

          Fastlane::Actions::IncrementVersionNumberAction.update_project_version(project, "MARKETING_VERSION", "1.2.3")
        end
      end

      it "returns the new version as return value" do
        project_path = project_with_version("1.0.0")

        result = increment_version_number("xcodeproj: '#{project_path}', bump_type: 'major'")

        expect(result).to eq(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER])
      end

      it "raises an exception when xcode project path wasn't found" do
        expect do
          increment_version_number("xcodeproj: '/nothere'")
        end.to raise_error("Could not find Xcode project")
      end

      it "raises an exception when user passes workspace" do
        expect do
          increment_version_number("xcodeproj: 'project.xcworkspace'")
        end.to raise_error("Please pass the path to the project, not the workspace")
      end

      ["A", "1.2.3.4", "1.2.3-pre"].each do |version|
        it "raises an exception when unable to calculate new version for #{version} (which does not match any of the supported schemes)" do
          project_path = project_with_version(version)

          expect do
            increment_version_number("xcodeproj: '#{project_path}'")
          end.to raise_error("Your current version (#{version}) does not respect the format A or A.B or A.B.C")
        end
      end
    end
  end
end
