describe Fastlane do
  describe Fastlane::FastFile do
    describe "AppStore Action" do
      it "is an alias for the deliver action" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appstore(skip_metadata: true)
        end").runner.execute(:test)

        expect(result[:skip_metadata]).to eq(true)
      end
    end
  end
end
