describe Fastlane do
  describe Fastlane::FastFile do
    describe "Produce Integration" do
      it "raises an error if non hash is passed" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
              produce('text')
            end").runner.execute(:test)
        end.to raise_error("You have to call the integration like `produce(key: \"value\")`. Run `fastlane action produce` for all available keys. Please check out the current documentation on GitHub.")
      end
    end
  end
end
