describe Fastlane do
  describe Fastlane::FastFile do
    describe "Jazzy" do
      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          jazzy
        end").runner.execute(:test)

        expect(result).to eq("jazzy")
      end
    end
  end
end
