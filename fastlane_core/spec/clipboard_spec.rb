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
