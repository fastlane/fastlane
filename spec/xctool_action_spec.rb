describe Fastlane do
  describe Fastlane::FastFile do
    describe "Deliver Integration" do

      it "works with default setting" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          xctool 'build test'
        end").runner.execute(:test)

        expect(result.first).to eq("xctool build test")
      end
    end
  end
end
