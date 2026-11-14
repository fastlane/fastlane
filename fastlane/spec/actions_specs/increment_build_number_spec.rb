describe Fastlane do
  describe Fastlane::FastFile do
    describe "Increment Build Number Integration" do
      let(:dir) { Dir.mktmpdir }

      def increment_build_number(options)
        Fastlane::FastFile.new.parse("lane :test do
          increment_build_number(#{options})
        end").runner.execute(:test)
      end

      describe "With agv enabled" do
        let(:project_path) do
          create_versioning_project(dir, build_settings: { "CURRENT_PROJECT_VERSION" => "40" }, info_plist: { "CFBundleVersion" => "40" })
        end
        let(:info_plist) { File.join(dir, "Info.plist") }

        it "increments the build number of the Xcode project" do
          result = increment_build_number("xcodeproj: '#{project_path}'")

          expect(result).to eq("41")
          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("41")
          expect(versioning_project_build_settings(project_path, "CURRENT_PROJECT_VERSION")).to eq(["41", "41"])
          expect(Xcodeproj::Plist.read_from_path(info_plist)["CFBundleVersion"]).to eq("41")
        end

        it "increments the whole-number part of the build number" do
          project_path = create_versioning_project(dir, build_settings: { "CURRENT_PROJECT_VERSION" => "41.2" })

          expect(increment_build_number("xcodeproj: '#{project_path}'")).to eq("42")
        end

        it "increments the highest build number when the build configurations use different build numbers" do
          project_path = create_versioning_project(dir) do |_project, target|
            target.build_configurations.first.build_settings["CURRENT_PROJECT_VERSION"] = "41"
            target.build_configurations.last.build_settings["CURRENT_PROJECT_VERSION"] = "9"
          end

          expect(increment_build_number("xcodeproj: '#{project_path}'")).to eq("42")
          expect(versioning_project_build_settings(project_path, "CURRENT_PROJECT_VERSION")).to eq(["42", "42"])
        end

        it "increments the build number of the only Xcode project in the current directory" do
          project_path

          result = Dir.chdir(dir) { increment_build_number("") }

          expect(result).to eq("41")
          expect(versioning_project_build_settings(project_path, "CURRENT_PROJECT_VERSION")).to eq(["41", "41"])
        end

        it "sets a custom build number" do
          result = increment_build_number("build_number: 24, xcodeproj: '#{project_path}'")

          expect(result).to eq("24")
          expect(versioning_project_build_settings(project_path, "CURRENT_PROJECT_VERSION")).to eq(["24", "24"])
          expect(Xcodeproj::Plist.read_from_path(info_plist)["CFBundleVersion"]).to eq("24")
        end

        it "accepts a custom build number that the project already has" do
          expect(increment_build_number("build_number: 40, xcodeproj: '#{project_path}'")).to eq("40")
        end

        it "sets a custom build number that only an xcconfig file holds, also when it is already set" do
          xcconfig = File.join(dir, "Config.xcconfig")
          File.write(xcconfig, "CURRENT_PROJECT_VERSION = 40\n")
          project_path = create_versioning_project(dir) do |project, target|
            reference = project.new_file("Config.xcconfig")
            target.build_configurations.each { |config| config.base_configuration_reference = reference }
          end

          2.times { expect(increment_build_number("build_number: 41, xcodeproj: '#{project_path}'")).to eq("41") }

          expect(File.read(xcconfig)).to eq("CURRENT_PROJECT_VERSION = 41\n")
        end

        it "skips info plist updating" do
          increment_build_number("build_number: 24, xcodeproj: '#{project_path}', skip_info_plist: true")

          expect(versioning_project_build_settings(project_path, "CURRENT_PROJECT_VERSION")).to eq(["24", "24"])
          expect(Xcodeproj::Plist.read_from_path(info_plist)["CFBundleVersion"]).to eq("40")
        end

        it "keeps Info.plist values that refer to a build setting" do
          project_path = create_versioning_project(dir, build_settings: { "CURRENT_PROJECT_VERSION" => "40" }, info_plist: { "CFBundleVersion" => "$(CURRENT_PROJECT_VERSION)" })

          increment_build_number("build_number: 24, xcodeproj: '#{project_path}'")

          expect(Xcodeproj::Plist.read_from_path(info_plist)["CFBundleVersion"]).to eq("$(CURRENT_PROJECT_VERSION)")
        end

        it "updates Info.plist files whose path starts with $(SRCROOT)" do
          project_path = create_versioning_project(dir, build_settings: { "CURRENT_PROJECT_VERSION" => "40" }, info_plist: { "CFBundleVersion" => "40" }) do |_project, target|
            target.build_configurations.each { |config| config.build_settings["INFOPLIST_FILE"] = "$(SRCROOT)/Info.plist" }
          end

          increment_build_number("build_number: 24, xcodeproj: '#{project_path}'")

          expect(Xcodeproj::Plist.read_from_path(info_plist)["CFBundleVersion"]).to eq("24")
        end

        it "properly removes new lines of the build number" do
          result = increment_build_number("build_number: '24\n', xcodeproj: '#{project_path}'")

          expect(result).to eq("24")
        end

        it "writes the build number without shell expansion" do
          increment_build_number("build_number: '42$HOME', xcodeproj: '#{project_path}'")

          expect(versioning_project_build_settings(project_path, "CURRENT_PROJECT_VERSION")).to eq(["42$HOME", "42$HOME"])
        end

        it "raises an exception when user passes workspace" do
          expect do
            increment_build_number("xcodeproj: 'project.xcworkspace'")
          end.to raise_error("Please pass the path to the project, not the workspace")
        end

        it "raises an exception when the current directory has more than one Xcode project" do
          FileUtils.mkdir_p(File.join(dir, "App.xcodeproj"))
          FileUtils.mkdir_p(File.join(dir, "Extension.xcodeproj"))

          expect do
            Dir.chdir(dir) { increment_build_number("build_number: 24") }
          end.to raise_error(/Could not find a single Xcode project/)
        end
      end

      describe "With agv not enabled" do
        let(:project_path) { create_versioning_project(dir, info_plist: { "CFBundleVersion" => "1" }) }

        it "raises an exception when agv not enabled" do
          expect do
            increment_build_number("xcodeproj: '#{project_path}'")
          end.to raise_error(/Apple Generic Versioning is not enabled./)
        end

        it "pass a custom build number to the tool" do
          result = increment_build_number("build_number: 21, xcodeproj: '#{project_path}'")

          expect(result).to eq('21')
          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq('21')
          expect(Xcodeproj::Plist.read_from_path(File.join(dir, "Info.plist"))["CFBundleVersion"]).to eq("21")
        end

        it "raises an exception when nothing in the project can hold a custom build number" do
          project_path = create_versioning_project(dir, info_plist: { "CFBundleVersion" => "$(CURRENT_PROJECT_VERSION)" })

          expect do
            increment_build_number("build_number: 21, xcodeproj: '#{project_path}'")
          end.to raise_error(/Could not store the build number 21/)
        end

        it "raises an exception when the only place for a custom build number is an Info.plist that the action skips" do
          expect do
            increment_build_number("build_number: 21, xcodeproj: '#{project_path}', skip_info_plist: true")
          end.to raise_error(/Could not store the build number 21/)
        end
      end
    end
  end
end
