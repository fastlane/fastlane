describe Fastlane do
  describe Fastlane::FastFile do
    describe "Get Build Number Integration" do
      let(:dir) { Dir.mktmpdir }

      it "gets the build number of the Xcode project" do
        project_path = create_versioning_project(dir, build_settings: { "CURRENT_PROJECT_VERSION" => "41" })

        result = Fastlane::FastFile.new.parse("lane :test do
          get_build_number(xcodeproj: '#{project_path}')
        end").runner.execute(:test)

        expect(result).to eq("41")
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("41")
      end

      it "gets the build number of the only Xcode project in the current directory" do
        create_versioning_project(dir, build_settings: { "CURRENT_PROJECT_VERSION" => "41" })

        result = Dir.chdir(dir) do
          Fastlane::FastFile.new.parse("lane :test do
            get_build_number
          end").runner.execute(:test)
        end

        expect(result).to eq("41")
      end

      it "raises an exception when the current directory has more than one Xcode project" do
        FileUtils.mkdir_p(File.join(dir, "App.xcodeproj"))
        FileUtils.mkdir_p(File.join(dir, "Extension.xcodeproj"))

        expect do
          Dir.chdir(dir) do
            Fastlane::FastFile.new.parse("lane :test do
              get_build_number
            end").runner.execute(:test)
          end
        end.to raise_error(/Could not find a single Xcode project/)
      end

      it "raises an exception when Apple Generic Versioning is not enabled" do
        project_path = create_versioning_project(dir)

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            get_build_number(xcodeproj: '#{project_path}')
          end").runner.execute(:test)
        end.to raise_error(/Apple Generic Versioning is not enabled/)
      end

      it "gets the highest build number when the build configurations use different build numbers" do
        project_path = create_versioning_project(dir) do |_project, target|
          target.build_configurations.first.build_settings["CURRENT_PROJECT_VERSION"] = "41"
          target.build_configurations.last.build_settings["CURRENT_PROJECT_VERSION"] = "9"
        end

        result = Fastlane::FastFile.new.parse("lane :test do
          get_build_number(xcodeproj: '#{project_path}')
        end").runner.execute(:test)

        expect(result).to eq("41")
      end

      it "returns false when Apple Generic Versioning is not enabled and the error is hidden" do
        project_path = create_versioning_project(dir)

        result = Fastlane::FastFile.new.parse("lane :test do
          get_build_number(xcodeproj: '#{project_path}', hide_error_when_versioning_disabled: true)
        end").runner.execute(:test)

        expect(result).to eq(false)
      end

      it "raises an exception when user passes workspace" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            get_build_number(xcodeproj: 'project.xcworkspace')
          end").runner.execute(:test)
        end.to raise_error("Please pass the path to the project, not the workspace")
      end
    end
  end
end
