describe Fastlane do
  describe Fastlane::ActionCollector do
    it "properly tracks the actions" do
      ENV.delete("FASTLANE_OPT_OUT_USAGE")

      ff = nil
      begin
        ff = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag(build_number: 0)
          add_git_tag(build_number: 1)
        end")
      rescue
      end

      result = ff.runner.execute(:test)

      expect(ff.collector.launches).to eq({
        add_git_tag: 2
      })
    end

    it "doesn't track unofficial actions" do
      ENV.delete("FASTLANE_OPT_OUT_USAGE")

      Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions") # load custom actions

      ff = nil
      begin
        ff = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag(build_number: 1)
          example_action
        end")
      rescue
      end

      result = ff.runner.execute(:test)

      expect(ff.collector.launches).to eq({
        add_git_tag: 1
      })
    end
  end
end
