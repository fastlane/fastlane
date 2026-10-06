describe Fastlane::Actions::LcovAction do
  describe "#run" do
    let(:action) { described_class }
    let(:commands) { [] }

    around do |example|
      Dir.mktmpdir("lcov_spec-") do |dir|
        @tmpdir = dir
        FastlaneSpec::Env.with_env_values('TMPDIR' => dir) { example.run }
      end
    end

    before do
      allow(action).to receive(:system) { |command| commands << command }
    end

    it "captures coverage into a fresh temporary directory" do
      action.run(project_name: "Example", scheme: "Example", arch: "x86_64", output_dir: "coverage_reports")

      cov_file = commands.first[/--output-file (\S+)/, 1]
      expect(cov_file).to start_with(@tmpdir)
      expect(cov_file).not_to eq(File.join(@tmpdir, "coverage.info"))
      expect(commands[1]).to include("--output #{cov_file}")
      expect(commands[2]).to start_with("genhtml #{cov_file} ")
    end
  end
end
