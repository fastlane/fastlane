require_relative '../internal/docs/markdown_links'

describe Fastlane::Internal::MarkdownLinks do
  let(:fixture_path) { 'spec/fixtures/markdown_links/page.md' }

  it 'reports missing files, missing headings and undefined references, and nothing else' do
    expected_errors = [
      "Broken link missing.md in '#{fixture_path}:25': no file spec/fixtures/markdown_links/missing.md",
      "Broken link #nowhere in '#{fixture_path}:25': no heading #nowhere in #{fixture_path}",
      "Broken link sub/other.md#nowhere in '#{fixture_path}:25': no heading #nowhere in spec/fixtures/markdown_links/sub/other.md",
      "Broken link sub/missing.md in '#{fixture_path}:26': no file spec/fixtures/markdown_links/sub/missing.md",
      "Undefined reference [nope] in '#{fixture_path}:26'",
      "Broken link sub/gone.md in '#{fixture_path}:29': no file spec/fixtures/markdown_links/sub/gone.md"
    ]
    expect(described_class.new(path: fixture_path).errors).to match_array(expected_errors)
  end

  it 'accepts a link back to a heading of the file that links to it' do
    expect(described_class.new(path: 'spec/fixtures/markdown_links/sub/other.md').errors).to be_empty
  end

  describe '.slug' do
    it 'follows GitHub: emphasis dropped, underscores inside words and code kept, punctuation removed' do
      expect(described_class.slug('Using _fastlane_ with `get_build_number`')).to eq('using-fastlane-with-get_build_number')
      expect(described_class.slug("What's gym?")).to eq('whats-gym')
      expect(described_class.slug('Use with [_sigh_](https://docs.fastlane.tools/actions/sigh/)')).to eq('use-with-sigh')
      expect(described_class.slug('Moved to our new <https://docs.fastlane.tools/actions/> page')).to eq('moved-to-our-new-httpsdocsfastlanetoolsactions-page')
    end
  end
end
