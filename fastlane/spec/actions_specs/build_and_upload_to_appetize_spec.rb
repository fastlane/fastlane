describe Fastlane::Actions::BuildAndUploadToAppetizeAction do
  describe "#run" do
    let(:action) { described_class }
    let(:xcodebuild_configs) { [] }

    around do |example|
      Dir.mktmpdir("build_and_upload_to_appetize_spec-") do |dir|
        @tmpdir = dir
        FastlaneSpec::Env.with_env_values('TMPDIR' => dir) { example.run }
      end
    end

    before do
      allow(Fastlane::Actions::XcodebuildAction).to receive(:run) do |configs|
        xcodebuild_configs << configs
        FileUtils.mkdir_p(File.join(configs[:derivedDataPath], "Example.app"))
      end
      allow(Fastlane::Actions::ZipAction).to receive(:run) { |params| params[:output_path] }
      allow(action).to receive(:other_action).and_return(double("other_action", appetize: nil))
    end

    it "builds into a fresh temporary directory and removes it" do
      action.run(xcodebuild: {}, api_token: "token", public_key: nil, note: nil, timeout: nil)

      build_dir = xcodebuild_configs.first[:derivedDataPath]
      expect(build_dir).to start_with(@tmpdir)
      expect(build_dir).not_to eq(File.join(@tmpdir, "fastlane_build"))
      expect(xcodebuild_configs.first[:xcargs]).to eq("CONFIGURATION_BUILD_DIR=#{build_dir}")
      expect(File).not_to exist(build_dir)
    end
  end
end
