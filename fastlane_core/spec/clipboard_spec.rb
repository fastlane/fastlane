# The only test in the suite that uses the real clipboard, and it should stay
# that way. There is one pasteboard per logged-in session, shared by every
# process on the machine, so two specs touching it on different workers race for
# it: that is fastlane#30210. Everywhere else the clipboard is mocked, which is
# what lets the suite run split across processes.
#
# This one is kept unmocked because it is the test of the pbcopy and pbpaste
# boundary itself, and mocking it would leave nothing verifying that boundary
# works at all. Keeping exactly one means there is nothing for it to race with.
#
# It does modify the user's environment while it runs. It saves the pasteboard
# and puts it back, but anything copied during that window is lost, which is the
# price of covering the real thing.
#
# If you need to assert that something reached the clipboard, mock
# FastlaneCore::Clipboard and assert against that rather than adding a second
# spec here.
describe FastlaneCore do
  describe FastlaneCore::Clipboard do
    describe '#copy and paste' do
      before(:each) do
        @test_message = "_fastlane_ is awesome"
      end

      it 'should work on supported environments', if: FastlaneCore::Clipboard.is_supported? do
        # Save clipboard
        clipboard = FastlaneCore::Clipboard.paste

        # Test copy and paste
        FastlaneCore::Clipboard.copy(content: @test_message)
        expect(FastlaneCore::Clipboard.paste).to eq(@test_message)

        # Restore clipboard
        FastlaneCore::Clipboard.copy(content: clipboard)
        expect(FastlaneCore::Clipboard.paste).to eq(clipboard)
      end

      it 'should throw on non-supported environment', if: !FastlaneCore::Clipboard.is_supported? do
        expect { FastlaneCore::Clipboard.copy(content: @test_message) }.to raise_error("'pbcopy' or 'pbpaste' command not found.")
        expect { FastlaneCore::Clipboard.paste }.to raise_error("'pbcopy' or 'pbpaste' command not found.")
      end
    end
  end
end
