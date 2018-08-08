describe Fastlane do
  describe Fastlane::FastFile do
    describe "app_store_build_number" do
      it "returns value as string (with build number as version string)" do
        allow(Fastlane::Actions::AppStoreBuildNumberAction).to receive(:get_build_number).and_return("1.2.3")

        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_build_number(username: 'name@example.com', app_identifier: 'x.y.z')
        end").runner.execute(:test)

        expect(result).to eq("1.2.3")
      end

      it "returns value as integer (with build number as version number)" do
        allow(Fastlane::Actions::AppStoreBuildNumberAction).to receive(:get_build_number).and_return("3")

        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_build_number(username: 'name@example.com', app_identifier: 'x.y.z')
        end").runner.execute(:test)

        expect(result).to eq(3)
      end
    end
  end
end