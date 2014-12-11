describe Fastlane do
  describe Fastlane::FastFile do
    describe "Deliver Integration" do

      it "works with default setting" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          deliver
        end").runner.execute(:test)
        expect(result.first).to eq("deliver")
      end

    end
  end
end
