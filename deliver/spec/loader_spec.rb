require 'deliver/loader'
require 'fakefs/spec_helpers'

describe Deliver::Loader do
  include(FakeFS::SpecHelpers)

  describe Deliver::Loader::LanguageFolder do
    let(:root) { '/some/root' }
    before { FileUtils.mkdir_p(root) }

    def directory_path(name)
      path = File.join(root, name)
      FileUtils.mkdir_p(path)
      path
    end

    describe '#new' do
      it 'should fail to initialize an instance unless given a directory path' do
        random_path = File.join(root, 'random_file')
        expect { described_class.new(random_path) }.to raise_error(ArgumentError)

        path = directory_path('directory')
        expect { described_class.new(path) }.not_to raise_error
      end
    end

    describe '#language' do
      let(:language) { FastlaneCore::Languages::ALL_LANGUAGES.sample }

      it 'should be same as directory name being language name' do
        expect(described_class.new(directory_path(language)).language).to eq(language)
      end

      it 'should be same as language name normalized even when case is different' do
        expect(described_class.new(directory_path(language.upcase)).language).to eq(language)
      end

      it 'should be nil for default folder' do
        expect(described_class.new(directory_path('default')).language).to be_nil
      end
    end

    describe '#valid?' do
      it 'should be valid for allowed directory names' do
        (FastlaneCore::Languages::ALL_LANGUAGES + Deliver::Loader::SPECIAL_DIR_NAMES).each do |name|
          expect(described_class.new(directory_path(name)).valid?).to be(true)
        end
        expect(described_class.new(directory_path('random')).valid?).to be(false)
      end
    end

    describe '#expandable?' do
      it 'should be true for specific directories' do
        Deliver::Loader::EXPANDABLE_DIR_NAMES.each do |name|
          expect(described_class.new(directory_path(name)).expandable?).to be(true)
        end
        expect(described_class.new(directory_path(FastlaneCore::Languages::ALL_LANGUAGES.sample)).expandable?).to be(false)
      end
    end

    describe '#skip?' do
      it 'should be true when exceptional directories' do
        Deliver::Loader::EXCEPTION_DIRECTORIES.each do |name|
          expect(described_class.new(directory_path(name)).skip?).to be(true)
        end
        expect(described_class.new(directory_path(FastlaneCore::Languages::ALL_LANGUAGES.sample)).skip?).to be(false)
        expect(described_class.new(directory_path(Deliver::Loader::SPECIAL_DIR_NAMES.sample)).skip?).to be(false)
      end
    end
  end

  describe '#language_folders' do
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
      @folders = Deliver::Loader.language_folders(@root, false)

      expect(@folders.size).not_to(eq(0))
    end

    it 'only returns directories regardless of case' do
      FileUtils.mkdir(File.join(@root, 'unrelated-dir'))
      @folders = Deliver::Loader.language_folders(@root, true)

      expect(@folders.size).not_to(eq(0))
      expected_languages = @languages[1..-1].map(&:downcase).sort
      actual_languages = @folders.map(&:basename).map(&:downcase).sort
      expect(actual_languages).to eq(expected_languages)
    end

    it 'raises error when a directory name contains an unsupported directory name' do
      allowed_directory_names = (@languages + Deliver::Loader::SPECIAL_DIR_NAMES)

      FileUtils.mkdir(File.join(@root, 'unrelated-dir'))
      expect do
        @folders = Deliver::Loader.language_folders(@root, false)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "Unsupported directory name(s) for screenshots/metadata in '#{@root}': unrelated-dir" \
                                                                 "\nValid directory names are: #{allowed_directory_names}" \
                                                                 "\n\nEnable 'ignore_language_directory_validation' to prevent this validation from happening")
    end

    it 'allows but ignores the special "fonts" directory used by frameit"' do
      FileUtils.mkdir(File.join(@root, 'fonts'))

      @folders = Deliver::Loader.language_folders(@root, false)

      basenames = @folders.map(&:basename)
      expect(basenames.include?('fonts')).to eq(false)
    end

    it 'should expand specific directories when they have sub language directories' do
      Deliver::Loader::SPECIAL_DIR_NAMES.each do |dirname|
        FileUtils.mkdir(File.join(@root, dirname))
        FileUtils.mkdir(File.join(@root, dirname, @languages.first))
      end

      folders_not_expanded = Deliver::Loader.language_folders(@root, true, false)
      folders_expanded = Deliver::Loader.language_folders(@root, true, true)

      expect(folders_not_expanded.any?(&:expandable?)).to be(true)
      expect(folders_expanded.any?(&:expandable?)).to be(false)

      expanded_special_folders = folders_expanded.select do |folder|
        folder.path.include?(Deliver::Loader::APPLE_TV_DIR_NAME) || folder.path.include?(Deliver::Loader::IMESSAGE_DIR_NAME)
      end
      # all expanded folder should have its language
      expect(expanded_special_folders.map(&:language).any?(&:nil?)).to be(false)
    end
  end

  describe "#load_app_screenshots" do
    include(FakeFS::SpecHelpers)

    def add_screenshot(file)
      FileUtils.mkdir_p(File.dirname(file))
      File.open(file, 'w') { |f| f << 'touch' }
    end

    def collect_screenshots_from_dir(dir)
      Deliver::Loader.load_app_screenshots(dir, false)
    end

    before do
      FakeFS::FileSystem.clone(File.join(Spaceship::ROOT, "lib", "assets", "displayFamilies.json"))
      allow(FastImage).to receive(:size) do |path|
        path.match(/{([0-9]+)x([0-9]+)}/).captures.map(&:to_i)
      end

      allow(FastImage).to receive(:type) do |path|
        # work out valid format symbol
        found = Deliver::AppScreenshotValidator::ALLOWED_SCREENSHOT_FILE_EXTENSION.find do |_, extensions|
          extensions.include?(File.extname(path).delete('.'))
        end
        found.first if found
      end
    end

    it "should not find any screenshots when the directory is empty" do
      screenshots = collect_screenshots_from_dir("/Screenshots")
      expect(screenshots.count).to eq(0)
    end

    it "should find screenshot when present in the directory" do
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(1)
      expect(screenshots.first.display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_IPHONE_47)
    end

    it "should find different languages" do
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}.jpg")
      add_screenshot("/Screenshots/fr-FR/iPhone8-01First{750x1334}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots")
      expect(screenshots.count).to eq(2)
      expect(screenshots.group_by(&:language).keys).to include("en-GB", "fr-FR")
    end

    it "should not collect regular screenshots if framed varieties exist" do
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}.jpg")
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}_framed.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(1)
      expect(screenshots.first.path).to eq("/Screenshots/en-GB/iPhone8-01First{750x1334}_framed.jpg")
    end

    it "should collect Apple Watch screenshots" do
      add_screenshot("/Screenshots/en-GB/AppleWatch-01First{368x448}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(1)
    end

    it "should continue to collect Apple Watch screenshots even when framed iPhone screenshots exist" do
      add_screenshot("/Screenshots/en-GB/AppleWatch-01First{368x448}.jpg")
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}.jpg")
      add_screenshot("/Screenshots/en-GB/iPhone8-01First{750x1334}_framed.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(2)
      expect(screenshots.group_by(&:display_type).keys).to include(Deliver::AppScreenshot::DisplayType::APP_WATCH_SERIES_4, Deliver::AppScreenshot::DisplayType::APP_IPHONE_47)
    end

    it "should support special appleTV directory" do
      add_screenshot("/Screenshots/appleTV/en-GB/01First{3840x2160}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(1)
      expect(screenshots.first.display_type).to eq(Deliver::AppScreenshot::DisplayType::APP_APPLE_TV)
    end

    it "should detect iMessage screenshots based on the directory they are contained within" do
      add_screenshot("/Screenshots/iMessage/en-GB/iPhone8-01First{750x1334}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(1)
      expect(screenshots.first.is_messages?).to be_truthy
    end

    it "should raise an error if unsupported screenshot sizes are in iMessage directory" do
      add_screenshot("/Screenshots/iMessage/en-GB/AppleTV-01First{3840x2160}.jpg")
      expect do
        collect_screenshots_from_dir("/Screenshots/")
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /Canceled uploading screenshot/)
    end
  end

  describe "#load_app_clip_header_images" do
    include(FakeFS::SpecHelpers)

    def add_header_image(file)
      FileUtils.mkdir_p(File.dirname(file))
      File.open(file, 'w') { |f| f << 'touch' }
    end

    def collect_header_images_from_dir(dir)
      Deliver::Loader.load_app_clip_header_images(dir, false)
    end

    before do
      allow(FastImage).to receive(:size).and_return([1800, 1200])
    end

    it "should not find any header images when the directory is empty" do
      header_images = collect_header_images_from_dir("/AppClipHeaderImages")
      expect(header_images.count).to eq(0)
    end

    it "should find header image when present in the directory" do
      add_header_image("/AppClipHeaderImages/en-US/header.jpg")
      header_images = collect_header_images_from_dir("/AppClipHeaderImages/")
      expect(header_images.count).to eq(1)
      expect(header_images.first.language).to eq("en-US")
    end

    it "should find header images from multiple languages" do
      add_header_image("/AppClipHeaderImages/en-US/header.jpg")
      add_header_image("/AppClipHeaderImages/ko/header.jpg")
      add_header_image("/AppClipHeaderImages/ja/header.jpg")
      header_images = collect_header_images_from_dir("/AppClipHeaderImages")
      expect(header_images.count).to eq(3)
      expect(header_images.map(&:language)).to contain_exactly("en-US", "ko", "ja")
    end

    it "should include default folder header image with nil language" do
      add_header_image("/AppClipHeaderImages/default/header.jpg")
      add_header_image("/AppClipHeaderImages/en-US/header.jpg")
      header_images = collect_header_images_from_dir("/AppClipHeaderImages")
      expect(header_images.count).to eq(2)

      default_image = header_images.find { |img| img.language.nil? }
      expect(default_image).not_to be_nil
      expect(default_image.path).to eq("/AppClipHeaderImages/default/header.jpg")
    end

    it "should validate header images are 1800x1200" do
      add_header_image("/AppClipHeaderImages/en-US/header.jpg")
      allow(FastImage).to receive(:size).and_return([1920, 1080])

      expect do
        collect_header_images_from_dir("/AppClipHeaderImages")
      end.to raise_error(FastlaneCore::Interface::FastlaneError)
    end

    it "should validate only one header image per language" do
      add_header_image("/AppClipHeaderImages/en-US/header1.jpg")
      add_header_image("/AppClipHeaderImages/en-US/header2.jpg")

      expect do
        collect_header_images_from_dir("/AppClipHeaderImages")
      end.to raise_error(FastlaneCore::Interface::FastlaneError)
    end

    it "should filter out nil languages before validation for duplicate check" do
      add_header_image("/AppClipHeaderImages/default/header1.jpg")
      add_header_image("/AppClipHeaderImages/default/header2.jpg")

      # Should not raise error for multiple images in default folder
      # since nil languages are filtered out during validation
      header_images = collect_header_images_from_dir("/AppClipHeaderImages")
      expect(header_images.count).to eq(2)
      expect(header_images.all? { |img| img.language.nil? }).to be(true)
    end
  end
end
