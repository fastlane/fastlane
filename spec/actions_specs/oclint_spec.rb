describe Fastlane do
  describe Fastlane::FastFile do
    describe "OCLint Integration" do
      it "raises an exception when not the default compile_commands.json is present" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            oclint
          end").runner.execute(:test)
        end.to raise_error("Could not find json compilation database at path 'compile_commands.json'".red)
      end
    end
  end
end
