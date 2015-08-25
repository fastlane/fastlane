describe Fastlane do
  describe Fastlane::FastFile do
    describe "is_ci" do
      it "returns the correct value" do
        result = Fastlane::FastFile.new.parse("lane :test do
          is_ci
        end").runner.execute(:test)

        expect(result).to eq(FastlaneCore::Helper.is_ci?)
      end

      it "works with a ? in the end" do
        result = Fastlane::FastFile.new.parse("lane :test do
          is_ci?
        end").runner.execute(:test)

        expect(result).to eq(FastlaneCore::Helper.is_ci?)
      end
    end
  end
end
