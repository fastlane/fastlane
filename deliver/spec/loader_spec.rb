require 'deliver/loader'
require 'fakefs/spec_helpers'

describe Deliver::Loader do
  include FakeFS::SpecHelpers

  before do
    @languages = FastlaneCore::Languages::ALL_LANGUAGES

    @root = '/some/root'
    FileUtils.mkdir_p(@root)

    # Add a file with a lang code
    File.open(File.join(@root, @languages.first), 'w') { |f| f << 'touch' }
    # Create dirs for all the other codes
    @languages[1..-1].each.with_index do |lang, index|
      FileUtils.mkdir(File.join(@root, (index.even? ? lang : lang.downcase)))
    end
  end

  it 'only returns directories in the specified directory' do
    @folders = Deliver::Loader.language_folders(@root)

    expect(@folders.size).not_to eq(0)
    expect(@folders.all? { |f| File.directory?(f) }).to eq(true)
  end

  it 'only returns directories regardless of case' do
    @folders = Deliver::Loader.language_folders(@root)

    expect(@folders.size).not_to eq(0)
    expected_languages = @languages[1..-1].map(&:downcase).sort
    actual_languages = @folders.map { |f| File.basename(f) }.map(&:downcase).sort
    expect(actual_languages).to eq(expected_languages)
  end

  it 'raises error when a directory name contains an unsupported language' do
    all_languages = (@languages + Deliver::Loader::SPECIAL_DIR_NAMES).map(&:downcase).freeze

    FileUtils.mkdir(File.join(@root, 'unrelated-dir'))
    expect do
      @folders = Deliver::Loader.language_folders(@root)
    end.to raise_error FastlaneCore::Interface::FastlaneError, "Unsupport language(s) for screenshots/metadata: unrelated-dir\n\nValid languages are: #{all_languages}"
  end
end
