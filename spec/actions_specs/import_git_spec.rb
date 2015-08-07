describe Fastlane do
  describe Fastlane::FastFile do
    describe "import_git" do
      it "allows the user to import a separate Fastfile from GIT source" do
        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/ImportGitFastfile')

        expect(ff.runner.execute(:main_lane)).to eq('such main') # from the git Fastfile
        expect(ff.runner.execute(:extended, :ios)).to eq('extended') # from the git Fastfile
        expect(ff.runner.execute(:test)).to eq(1) # from the git Fastfile
        expect(ff.runner.execute(:new_main_lane)).to eq('such new main lane') # from the original Fastfile

        # This should not raise an exception
      end

      it "raises an exception when no path is given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            import_git
          end").runner.execute(:test)
        }.to raise_error("Please pass a path to the `import` action".red)
      end
    end
  end
end
