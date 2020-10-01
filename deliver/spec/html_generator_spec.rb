require 'deliver/html_generator'
require 'tmpdir'

describe Deliver::HtmlGenerator do
  let(:generator) { Deliver::HtmlGenerator.new }

  describe :render do
    let(:screenshots) { [] }

    context 'minimal configuration' do
      let(:options) do
        {
          name: { 'en-US' => 'Fastlane Demo' },
          description: { 'en-US' => 'Demo description' }
        }
      end

      it 'renders HTML' do
        expect(render(options, screenshots)).to match(/<html>/)
      end
    end

    context 'with keywords' do
      let(:options) do
        {
          name: { 'en-US' => 'Fastlane Demo' },
          description: { 'en-US' => 'Demo description' },
          keywords: { 'en-US' => 'Some, key, words' }
        }
      end

      it 'renders HTML' do
        capture = render(options, screenshots)
        expect(capture).to match(/<html>/)
        expect(capture).to include('<li>Some</li>')
        expect(capture).to include('<li>key</li>')
        expect(capture).to include('<li>words</li>')
      end
    end

    context 'with an app icon' do
      let(:options) do
        {
          name: { 'en-US' => 'Fastlane Demo' },
          description: { 'en-US' => 'Demo description' },
          app_icon: 'fastlane/metadata/app_icon.png'
        }
      end

      it 'renders HTML' do
        capture = render(options, screenshots)
        expect(capture).to match(/<html>/)
        expect(capture).to include('app_icon.png')
      end
    end

    private

    def render(options, screenshots)
      Dir.mktmpdir do |dir|
        path = generator.render(options, screenshots, dir)
        return File.read(path)
      end
    end
  end

  describe :split_keywords do
    context 'only commas' do
      let(:keywords) { 'One,Two, Three, Four Token,' }

      it 'splits correctly' do
        expected = ['One', 'Two', 'Three', 'Four Token']
        expect(generator.split_keywords(keywords)).to eq(expected)
      end
    end

    context 'only newlines' do
      let(:keywords) { "One\nTwo\r\nThree\nFour Token\n" }

      it 'splits correctly' do
        expected = ['One', 'Two', 'Three', 'Four Token']
        expect(generator.split_keywords(keywords)).to eq(expected)
      end
    end

    context 'mixed' do
      let(:keywords) { "One,Two, Three, Four Token,Or\nNewlines\r\nEverywhere" }

      it 'splits correctly' do
        expected = [
          'One',
          'Two',
          'Three',
          'Four Token',
          'Or',
          'Newlines',
          'Everywhere'
        ]
        expect(generator.split_keywords(keywords)).to eq(expected)
      end
    end
  end
end
