describe Fastlane do
  describe Fastlane::FastFile do
    describe "Opt Out Usage" do
      it "works as expected" do
        Fastlane::FastFile.new.parse("lane :test do
          opt_out_usage
        end").runner.execute(:test)
        expect(ENV['FASTLANE_OPT_OUT_USAGE']).to eq("YES")
      end
    end
  end
end
