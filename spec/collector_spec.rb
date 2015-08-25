describe Fastlane do
  describe Fastlane::ActionCollector do
    it "properly tracks the actions" do
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

      expect(ff.collector.launches).to eq({
        snapshot: 2
      })
    end

    it "doesn't track unofficial actions" do
      ENV.delete("FASTLANE_OPT_OUT_USAGE")

      Fastlane::Actions.load_external_actions("spec/fixtures/actions") # load custom actions

      ff = nil
      begin
        ff = Fastlane::FastFile.new.parse("lane :test do
          example_action
          snapshot
        end")
      rescue
      end

      result = ff.runner.execute(:test)

      expect(ff.collector.launches).to eq({
        snapshot: 1
      })
    end
  end
end
