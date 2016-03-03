describe Frameit do
  describe Frameit::Editor do
    context 'fonts' do
      def fake_screenshot(language)
        default_size = Frameit::Editor::FONT_SIZE_REFERENCE_WIDTH
        OpenStruct.new({
          path: "fastlane/#{language}sometitle.png",
          size: [default_size, -1]
        })
      end

      def make_editor_with_config(config_path, language)
        config_file = Frameit::ConfigParser.new.load(config_path)
        screenshot = fake_screenshot(language)

        config = config_file.fetch_value(screenshot.path)

        editor = Frameit::Editor.new

        editor.screenshot = screenshot

        # TODO: This should probably be a collaborator instead a mock
        expect(editor).to receive(:fetch_config).at_least(:once).and_return config

        editor
      end

      describe 'font typeface' do
        it 'finds a font that matches en_US' do
          editor = make_editor_with_config('./spec/fixtures/example_frame_file.json', 'en_US')

          expect(editor.send(:font, 'title')).to match(/fake_western_font.otf/)
        end

        it 'finds a font that matches zh-Hans' do
          editor = make_editor_with_config('./spec/fixtures/example_frame_file.json', 'zh-Hans')

          expect(editor.send(:font, 'title')).to match(/fake_cjk_font.otf/)
        end

        it 'finds a default font' do
          editor = make_editor_with_config('./spec/fixtures/example_frame_file.json', 'NOT_A_REAL_LANGUAGE')

          expect(editor.send(:font, 'title')).to be_nil
        end

        it 'fails to find an unsupported language' do
          editor = make_editor_with_config('./spec/fixtures/example_frame_file.json', 'NOT_A_REAL_LANGUAGE')

          expect(editor.send(:font, 'keyword')).to match(/fake_font.otf/)
        end
      end

      describe 'font size' do
        it 'finds a font size that matches one language' do
          editor = make_editor_with_config('./spec/fixtures/example_frame_file.json', 'da_DK')

          expect(editor.send(:font_size, 'title')).to eq(48)
        end

        it 'finds a font size that matches a different language' do
          editor = make_editor_with_config('./spec/fixtures/example_frame_file.json', 'ja_JP')

          expect(editor.send(:font_size, 'title')).to eq(28)
        end

        it 'fails to find an unsupported language' do
          editor = make_editor_with_config('./spec/fixtures/example_frame_file.json', 'NOT_A_REAL_LANGUAGE')

          expect(editor.send(:font_size, 'title')).to be_nil
        end

        it 'does not find a default size' do
          editor = make_editor_with_config('./spec/fixtures/example_frame_file.json', 'NOT_A_REAL_LANGUAGE')

          expect(editor.send(:font_size, 'keyword')).to be_nil
        end
      end
    end
  end
end
