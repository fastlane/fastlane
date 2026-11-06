describe Fastlane do
  describe Fastlane::FastFile do
    describe "update_project_code_signing" do
      around do |example|
        Dir.mktmpdir("fl_spec_code_signing") do |dir|
          @project = File.join(dir, "App.xcodeproj")
          FileUtils.mkdir_p(@project)
          File.write(File.join(@project, "project.pbxproj"), "PROVISIONING_PROFILE = \"OLD\";\n")
          FastlaneCore::Helper.with_env_values("SIGH_UUID" => nil) { example.run }
        end
      end

      def run_action(arguments)
        Fastlane::FastFile.new.parse("lane :test do
          update_project_code_signing(path: '#{@project}', #{arguments})
        end").runner.execute(:test)
        File.read(File.join(@project, "project.pbxproj"))
      end

      it "sets the profile from :uuid" do
        expect(run_action("uuid: 'NEW'")).to eq("PROVISIONING_PROFILE = \"NEW\";\n")
      end

      it "sets the profile from the deprecated :udid alone" do
        expect(run_action("udid: 'NEW'")).to eq("PROVISIONING_PROFILE = \"NEW\";\n")
      end

      it "prefers :uuid when both are given" do
        expect(run_action("uuid: 'NEW', udid: 'OTHER'")).to eq("PROVISIONING_PROFILE = \"NEW\";\n")
      end
    end
  end
end
