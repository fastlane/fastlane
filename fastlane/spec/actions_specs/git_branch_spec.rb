describe Fastlane::Actions::GitBranchAction do
  describe "CI set ENV values" do
    Fastlane::Actions::SharedValues::GIT_BRANCH_ENV_VARS.each do |env_var|
      it "can control the output of the action with #{env_var}" do
        FastlaneSpec::Env.with_env_values(env_var => "#{env_var}-branch-name") do
          result = Fastlane::FastFile.new.parse("lane :test do
            git_branch
          end").runner.execute(:test)

          expect(result).to eq("#{env_var}-branch-name")
        end
      end
    end
  end

  describe "with no CI set ENV values" do
    it "gets the value from Git directly" do
      expect(Fastlane::Actions::GitBranchAction).to receive(:`)
        .with('git symbolic-ref HEAD --short 2>/dev/null')
        .and_return('branch-name')

      result = Fastlane::FastFile.new.parse("lane :test do
        git_branch
      end").runner.execute(:test)

      expect(result).to eq("branch-name")
    end
  end
end
