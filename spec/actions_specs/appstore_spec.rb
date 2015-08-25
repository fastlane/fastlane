describe Fastlane do
  describe Fastlane::FastFile do
    describe "AppStore Action" do
      it "merges the passed parameter with the default values" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appstore
        end").runner.execute(:test)

        expect(result[:beta]).to eq(false)

        path = File.expand_path('..', Dir.pwd)
        options = {force: false, skip_deploy: false, metadata_only: false, deliver_file_path: path, beta: false}
        expect(result.values).to eq(options)
      end

      it "uses the passed skip_deploy value if given" do
        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            appstore(beta: true)
          end").runner.execute(:test)
        end.to raise_error(/option 'beta' in the list of available options: force, skip_deploy, metadata_only, deliver_file_path/)
      end

      it "uses the passed skip_deploy value if given" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appstore(skip_deploy: true)
        end").runner.execute(:test)

        path = File.expand_path('..', Dir.pwd)
        expect(result.values).to eq({force: false, skip_deploy: true, metadata_only: false, deliver_file_path: path, beta: false})
      end
    end
  end
end
