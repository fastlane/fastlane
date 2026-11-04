describe Fastlane do
  describe Fastlane::FastFile do
    describe "Clipboard Integration" do
      if FastlaneCore::Helper.mac?
        it "properly stores the value in the clipboard" do
          str = "Some value: #{Time.now.to_i}"

          # Asserted against the helper rather than the real pasteboard. There
          # is one pasteboard per machine, shared by every process, so writing
          # to it here overwrote what spaceship's spaceauth specs had saved on
          # another worker. What this example is about is the action passing its
          # value through, not pbcopy itself. See fastlane#30210.
          expect(FastlaneCore::Clipboard).to receive(:copy).with(content: str)

          Fastlane::FastFile.new.parse("lane :test do
            clipboard(value: '#{str}')
          end").runner.execute(:test)
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
