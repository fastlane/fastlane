describe Fastlane do
  describe Fastlane::FastFile do
    describe "Increment Version Number Integration" do
      {
          "1" => "2",
          "1.1" => "1.2",
          "1.1.1" => "1.1.2"
      }.each do |from_version, to_version|
        it "increments all targets' version number from #{from_version} to #{to_version}" do
          expect(Fastlane::Actions).to receive(:sh)
            .with(/agvtool what-marketing-version/, any_args)
            .once
            .and_return(from_version)
          Fastlane::FastFile.new.parse("lane :test do
            increment_version_number
          end").runner.execute(:test)

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version #{to_version}/)
        end
      end

      ["1.0", "10"].each do |version|
        it "raises an exception when trying to increment patch version number for #{version} (which has no patch number)" do
          expect(Fastlane::Actions).to receive(:sh)
            .with(/agvtool what-marketing-version/, any_args)
            .once
            .and_return(version)

          expect do
            Fastlane::FastFile.new.parse("lane :test do
              increment_version_number(bump_type: 'patch')
            end").runner.execute(:test)
          end.to raise_error("Can't increment version")
        end
      end

      {
        "1.0.0" => "1.1.0",
        "10.13" => "10.14"
      }.each do |from_version, to_version|
        it "increments all targets' minor version number from #{from_version} to #{to_version}" do
          expect(Fastlane::Actions).to receive(:sh)
            .with(/agvtool what-marketing-version/, any_args)
            .once
            .and_return(from_version)
          Fastlane::FastFile.new.parse("lane :test do
            increment_version_number(bump_type: 'minor')
          end").runner.execute(:test)

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version #{to_version}/)
        end
      end

      it "raises an exception when trying to increment minor version number for 12 (which has no minor number)" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return("12")

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            increment_version_number(bump_type: 'minor')
          end").runner.execute(:test)
        end.to raise_error("Can't increment version")
      end

      {
        "1.0.0" => "2.0.0",
        "10.13" => "11.0",
        "12" => "13"
      }.each do |from_version, to_version|
        it "it increments all targets' major version number from #{from_version} to #{to_version}" do
          expect(Fastlane::Actions).to receive(:sh)
            .with(/agvtool what-marketing-version/, any_args)
            .once
            .and_return(from_version)
          Fastlane::FastFile.new.parse("lane :test do
            increment_version_number(bump_type: 'major')
          end").runner.execute(:test)

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version #{to_version}/)
        end
      end

      ["1.4.3", "1.0", "10"].each do |version|
        it "passes a custom version number #{version}" do
          result = Fastlane::FastFile.new.parse("lane :test do
            increment_version_number(version_number: \"#{version}\")
          end").runner.execute(:test)

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version #{version}/)
        end
      end

      it "prefers a custom version number over a boring version bump" do
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number(version_number: '1.77.3', bump_type: 'major')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 1.77.3/)
      end

      it "automatically removes new lines from the version number" do
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number(version_number: '1.77.3\n', bump_type: 'major')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to end_with("&& agvtool new-marketing-version 1.77.3")
      end

      it "resolves $(MARKETING_VERSION) using get_version_number action" do
        from_version = "$(MARKETING_VERSION)"
        resolved_version = "1.2.3"
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return(from_version)

        expect(Fastlane::Actions::GetVersionNumberAction).to receive(:run)
          .with(xcodeproj: nil)
          .and_return(resolved_version)

        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 1.2.4/)
      end

      it "updates MARKETING_VERSION build settings after agvtool when the version is stored in the Xcode project" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return("$(MARKETING_VERSION)")

        expect(Fastlane::Actions::GetVersionNumberAction).to receive(:run)
          .with(xcodeproj: nil)
          .and_return("1.2.3")

        allow(Fastlane::Helper).to receive(:test?)
          .and_return(false)

        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool new-marketing-version 1.2.4/)
          .once

        expect(Fastlane::Actions::IncrementVersionNumberAction).to receive(:update_project_version_build_setting)
          .with(nil, "MARKETING_VERSION", "1.2.4")

        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.2.4")
      end

      it "updates MARKETING_VERSION build settings when a custom version number is provided" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return("1.2.3")

        allow(Fastlane::Helper).to receive(:test?)
          .and_return(false)

        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool new-marketing-version 2.0.0/)
          .once

        expect(Fastlane::Actions::IncrementVersionNumberAction).to receive(:update_project_version_build_setting)
          .with(nil, "MARKETING_VERSION", "2.0.0")

        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number(version_number: '2.0.0')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("2.0.0")
      end

      it "does not require an Xcode project when updating a custom version number" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return("1.2.3")

        allow(Fastlane::Helper).to receive(:test?)
          .and_return(false)

        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool new-marketing-version 2.0.0/)
          .once

        expect(Fastlane::Helper::XcodeprojHelper).not_to receive(:get_project!)

        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do
            Fastlane::FastFile.new.parse("lane :test do
              increment_version_number(version_number: '2.0.0')
            end").runner.execute(:test)
          end
        end

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("2.0.0")
      end

      it "skips the update when multiple root projects exist and no project is provided" do
        Dir.mktmpdir do |dir|
          FileUtils.mkdir_p(File.join(dir, "App.xcodeproj"))
          FileUtils.mkdir_p(File.join(dir, "Extension.xcodeproj"))

          Dir.chdir(dir) do
            expect(Fastlane::Helper::XcodeprojHelper).not_to receive(:get_project!)

            expect do
              Fastlane::Actions::IncrementVersionNumberAction.update_project_version_build_setting(nil, "MARKETING_VERSION", "2.0.0")
            end.not_to raise_error
          end
        end
      end

      it "resolves ${MARKETING_VERSION} using get_version_number action" do
        from_version = "${MARKETING_VERSION}"
        resolved_version = "1.2.3"
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return(from_version)

        expect(Fastlane::Actions::GetVersionNumberAction).to receive(:run)
          .with(xcodeproj: nil)
          .and_return(resolved_version)
        expect(UI).to receive(:verbose)
          .with("agvtool returned ${MARKETING_VERSION}, resolving it...")

        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 1.2.4/)
      end

      it "updates MARKETING_VERSION build settings when the version is stored in the Xcode project" do
        build_configuration = Struct.new(:build_settings)
        project_config = build_configuration.new({ "MARKETING_VERSION" => "1.0.0" })
        target_config = build_configuration.new({ "MARKETING_VERSION" => "1.0.0" })
        other_config = build_configuration.new({ "CURRENT_PROJECT_VERSION" => "42" })
        target = double("target", build_configurations: [target_config, other_config])
        project = double("project", build_configurations: [project_config], targets: [target])

        expect(Fastlane::Helper::XcodeprojHelper).to receive(:get_project!)
          .with("App.xcodeproj")
          .and_return(project)
        expect(project).to receive(:save)

        Fastlane::Actions::IncrementVersionNumberAction.update_project_version_build_setting("App.xcodeproj", "MARKETING_VERSION", "1.2.3")

        expect(project_config.build_settings["MARKETING_VERSION"]).to eq("1.2.3")
        expect(target_config.build_settings["MARKETING_VERSION"]).to eq("1.2.3")
        expect(other_config.build_settings["CURRENT_PROJECT_VERSION"]).to eq("42")
      end

      it "does not save the Xcode project when MARKETING_VERSION is not set" do
        build_configuration = Struct.new(:build_settings)
        project_config = build_configuration.new({ "CURRENT_PROJECT_VERSION" => "42" })
        target_config = build_configuration.new({ "PRODUCT_BUNDLE_IDENTIFIER" => "tools.fastlane.example" })
        target = double("target", build_configurations: [target_config])
        project = double("project", build_configurations: [project_config], targets: [target])

        expect(Fastlane::Helper::XcodeprojHelper).to receive(:get_project!)
          .with("App.xcodeproj")
          .and_return(project)
        expect(project).not_to receive(:save)

        Fastlane::Actions::IncrementVersionNumberAction.update_project_version_build_setting("App.xcodeproj", "MARKETING_VERSION", "1.2.3")

        expect(project_config.build_settings["CURRENT_PROJECT_VERSION"]).to eq("42")
        expect(target_config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"]).to eq("tools.fastlane.example")
      end

      it "does not save the Xcode project when only an xcconfig changed" do
        project = double("project")

        expect(Fastlane::Helper::XcodeprojHelper).to receive(:get_project!)
          .with("App.xcodeproj")
          .and_return(project)
        expect(Fastlane::Helper::XcodeprojHelper).to receive(:update_project_build_setting)
          .with(project, "MARKETING_VERSION", "1.2.3")
          .and_return(project: false, xcconfig: true)
        expect(project).not_to receive(:save)

        Fastlane::Actions::IncrementVersionNumberAction.update_project_version_build_setting("App.xcodeproj", "MARKETING_VERSION", "1.2.3")
      end

      it "returns the new version as return value" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return("1.0.0")
        result = Fastlane::FastFile.new.parse("lane :test do
          increment_version_number(bump_type: 'major')
        end").runner.execute(:test)

        expect(result).to eq(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER])
      end

      it "raises an exception when xcode project path wasn't found" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            increment_version_number(xcodeproj: '/nothere')
          end").runner.execute(:test)
        end.to raise_error("Could not find Xcode project")
      end

      it "raises an exception when user passes workspace" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            increment_version_number(xcodeproj: 'project.xcworkspace')
          end").runner.execute(:test)
        end.to raise_error("Please pass the path to the project, not the workspace")
      end

      ["A", "1.2.3.4", "1.2.3-pre"].each do |version|
        it "raises an exception when unable to calculate new version for #{version} (which does not match any of the supported schemes)" do
          expect(Fastlane::Actions).to receive(:sh)
            .with(/agvtool what-marketing-version/, any_args)
            .once
            .and_return(version)
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              increment_version_number
            end").runner.execute(:test)
          end.to raise_error("Your current version (#{version}) does not respect the format A or A.B or A.B.C")
        end
      end
    end
  end
end
