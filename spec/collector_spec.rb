describe Fastlane do
  describe Fastlane::ActionCollector do
    it "works with :noclean" do
      ENV.delete("FASTLANE_OPT_OUT_USAGE")

      ff = nil
      begin
        ff = Fastlane::FastFile.new.parse("lane :test do
          snapshot(noclean: true)
          snapshot
        end")
      rescue
      end

      result = ff.runner.execute(:test)

      expect(ff.collector.launches).to eq(snapshot: 2)
    end
  end
end
