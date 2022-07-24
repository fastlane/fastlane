describe Fastlane::Notification::Slack do
  describe Fastlane::Notification::Slack::LinkConverter do
    it 'should convert HTML anchor tag to Slack link format' do
      {
        %|Hello <a href="https://fastlane.tools">fastlane</a>| => 'Hello <https://fastlane.tools|fastlane>',
        %|Hello <a href='https://fastlane.tools'>fastlane</a>| => 'Hello <https://fastlane.tools|fastlane>',
        %|Hello <a id="foo" href="https://fastlane.tools">fastlane</a>| => 'Hello <https://fastlane.tools|fastlane>',
        %|Hello <a href="https://fastlane.tools">fastlane</a> <a href="https://github.com/fastlane">GitHub</a>| => 'Hello <https://fastlane.tools|fastlane> <https://github.com/fastlane|GitHub>'
      }.each do |input, output|
        expect(described_class.convert(input)).to eq(output)
      end
    end

    it 'should convert Markdown link to Slack link format' do
      {
        %|Hello [fastlane](https://fastlane.tools)| => 'Hello <https://fastlane.tools|fastlane>',
        %|Hello [fastlane](mailto:fastlane@fastlane.tools)| => 'Hello <mailto:fastlane@fastlane.tools|fastlane>',
        %|Hello [fastlane](https://fastlane.tools) [GitHub](https://github.com/fastlane)| => 'Hello <https://fastlane.tools|fastlane> <https://github.com/fastlane|GitHub>',
        %|Hello [[fastlane](https://fastlane.tools) in brackets]| => 'Hello [<https://fastlane.tools|fastlane> in brackets]',
        %|Hello [](https://fastlane.tools)| => 'Hello <https://fastlane.tools>',
        %|Hello ([fastlane](https://fastlane.tools) in parens)| => 'Hello (<https://fastlane.tools|fastlane> in parens)',
        %|Hello ([fastlane(:rocket:)](https://fastlane.tools) in parens)| => 'Hello (<https://fastlane.tools|fastlane(:rocket:)> in parens)'
      }.each do |input, output|
        expect(described_class.convert(input)).to eq(output)
      end
    end
  end
end
