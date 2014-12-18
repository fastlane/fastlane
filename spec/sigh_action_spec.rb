describe Fastlane do
  describe Fastlane::FastFile do
    describe "Sigh Integration" do

      it "works with default setting" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          sigh
        end").runner.execute(:test)
        expect(result).to eq("AppStore")
      end

      it "supports ad hoc profiles" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          sigh :adhoc
        end").runner.execute(:test)
        expect(result).to eq("AdHoc")
      end

      it "supports development profiles" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          sigh :development
        end").runner.execute(:test)
        expect(result).to eq("Development")
      end

    end
  end
end
