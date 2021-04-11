require 'fastlane_core/lib/fastlane_core/clipboard'

describe FastlaneCore do
  describe FastlaneCore::Clipboard do

    describe '#copy and paste' do
      it 'should work on macOS environment', :if => FastlaneCore::Helper.mac? do
        # Save clipboard
        clipboard = FastlaneCore::Clipboard.paste

        # Test copy and paste
        FastlaneCore::Clipboard.copy(content: "_fastlane_ is awesome")
        expect(FastlaneCore::Clipboard.paste).to eq("_fastlane_ is awesome")

        # Restore clipboard
        FastlaneCore::Clipboard.copy(content: clipboard)
        expect(FastlaneCore::Clipboard.paste).to eq(clipboard)
      end

      it 'should throw on non-macOS environment', :if => !FastlaneCore::Helper.mac? do
        expect { FastlaneCore::Clipboard.copy(content: "_fastlane_ is awesome") }.to raise_error("Clipboard.copy is only supported in macOS environment.")
        expect { FastlaneCore::Clipboard.paste }.to raise_error("Clipboard.paste is only supported in macOS environment.")
      end
    end
  end
end
