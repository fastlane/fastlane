describe Fastlane do
  describe Fastlane::FastFile do
    describe "bundle install action" do
      it "default use case" do
        expect(Fastlane::Actions::BundleInstallAction).to receive(:gemfile_exists?).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          bundle_install
        end").runner.execute(:test)

        expect(result).to eq("bundle install")
      end
    end
  end
end
