describe Fastlane do
  describe Fastlane::FastFile do
    describe "danger integration" do
      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger")
      end

      it "no bundle exec" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(use_bundle_exec: false)
        end").runner.execute(:test)

        expect(result).to eq("danger")
      end
    end
  end
end
