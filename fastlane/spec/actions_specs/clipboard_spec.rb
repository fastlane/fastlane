describe Fastlane do
  describe Fastlane::FastFile do
    describe "Clipboard Integration" do
      if FastlaneCore::Helper.is_mac?
        it "properly stores the value in the clipboard" do
          str = "Some value: #{Time.now.to_i}"

          value = Fastlane::FastFile.new.parse("lane :test do
            clipboard(value: '#{str}')
          end").runner.execute(:test)

          expect(`pbpaste`).to eq(str)
        end
      end

      it "raises an error if the value is passed without a hash" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            clipboard 'Some Value!'
          end").runner.execute(:test)
        end.to raise_error("You have to call the integration like `clipboard(key: \"value\")`. Run `fastlane action clipboard` for all available keys. Please check out the current documentation on GitHub.")
      end
    end
  end
end
