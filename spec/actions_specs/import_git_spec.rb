describe Fastlane do
  describe Fastlane::FastFile do
    describe "import_from_git" do
      it "raises an exception when no path is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            import_from_git
          end").runner.execute(:test)
        end.to raise_error("Please pass a path to the `import_from_git` action".red)
      end
    end
  end
end
