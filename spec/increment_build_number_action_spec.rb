describe Fastlane do
  describe Fastlane::FastFile do
    describe "Increment Build Number Integration" do

      it "increments the build number of the Xcode project" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          increment_build_number
        end").runner.execute(:test)
        expect(result).to eq("agvtool next-version -all")
      end

      it "pass a custom build number to the tool" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          increment_build_number 24
        end").runner.execute(:test)
        expect(result).to eq("agvtool new-version -all 24")
      end
    end
  end
end
