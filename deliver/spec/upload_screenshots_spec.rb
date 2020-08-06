require 'deliver/upload_screenshots'
require 'fakefs/spec_helpers'

describe Deliver::UploadScreenshots do
  describe "#collect_screenshots_for_languages (screenshot collection)" do
    include(FakeFS::SpecHelpers)

    def add_screenshot(file)
      FileUtils.mkdir_p(File.dirname(file))
      File.open(file, 'w') { |f| f << 'touch' }
    end

    def collect_screenshots_from_dir(dir)
      Deliver::UploadScreenshots.new.collect_screenshots_for_languages(dir, false)
    end

    before do
      FakeFS::FileSystem.clone(File.join(Spaceship::ROOT, "lib", "assets", "displayFamilies.json"))
      allow(FastImage).to receive(:size) do |path|
        path.match(/{([0-9]+)x([0-9]+)}/).captures.map(&:to_i)
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
      expect(screenshots.first.screen_size).to eq(Deliver::AppScreenshot::ScreenSize::IOS_47)
    end

    it "should not collect iPhone XR screenshots" do
      add_screenshot("/Screenshots/en-GB/iPhoneXR-01First{828x1792}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(0)
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
      expect(screenshots.group_by(&:device_type).keys).to include("APP_WATCH_SERIES_4", "APP_IPHONE_47")
    end

    it "should support special appleTV directory" do
      add_screenshot("/Screenshots/appleTV/en-GB/01First{3840x2160}.jpg")
      screenshots = collect_screenshots_from_dir("/Screenshots/")
      expect(screenshots.count).to eq(1)
      expect(screenshots.first.device_type).to eq("APP_APPLE_TV")
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
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "Unsupported screen size [3840, 2160] for path '/Screenshots/iMessage/en-GB/AppleTV-01First{3840x2160}.jpg'")
    end
  end

  describe '#delete_screenshots' do
    context 'when localization has a screenshot' do
      it 'should delete screenshots that AppScreenshotIterator gives' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot', id: 'some-id')
        # return empty by `app_screenshots` as `each_app_screenshot_set` mocked needs it empty
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        screenshots_per_language = { 'en-US' => [] }

        allow_any_instance_of(Deliver::AppScreenshotIterator).to receive(:each_app_screenshot).and_yield(localization, app_screenshot_set, app_screenshot)
        allow_any_instance_of(Deliver::AppScreenshotIterator).to receive(:each_app_screenshot_set).and_return([[localization, app_screenshot_set]])

        expect(app_screenshot).to receive(:delete!).once
        described_class.new.delete_screenshots([localization], screenshots_per_language)
      end
    end

    context 'when deletion fails once' do
      it 'should retry to delete screenshots' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot', id: 'some-id')
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        screenshots_per_language = { 'en-US' => [] }

        allow_any_instance_of(Deliver::AppScreenshotIterator).to receive(:each_app_screenshot).and_yield(localization, app_screenshot_set, app_screenshot)
        # Return an screenshot once to fail validation and then return empty next time to pass it
        allow(app_screenshot_set).to receive(:app_screenshots).exactly(2).times.and_return([app_screenshot], [])
        allow_any_instance_of(Deliver::AppScreenshotIterator).to receive(:each_app_screenshot_set).and_return([[localization, app_screenshot_set]])

        # Try `delete!` twice by retry
        expect(app_screenshot).to receive(:delete!).twice
        described_class.new.delete_screenshots([localization], screenshots_per_language)
      end
    end
  end

  describe '#upload_screenshots' do
    subject { described_class.new }

    before do
      # mock these methods partially to simplfy test cases
      allow(subject).to receive(:wait_for_complete)
      allow(subject).to receive(:retry_upload_screenshots_if_needed)
    end

    context 'when localization has no screenshot uploaded' do
      it 'should upload screenshots with app_screenshot_set' do
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        local_screenshot = double('Deliver::AppScreenshot',
                                  path: '/path/to/screenshot',
                                  language: 'en-US',
                                  device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        screenshots_per_language = { 'en-US' => [local_screenshot] }
        allow(described_class).to receive(:calculate_checksum).and_return('checksum')

        expect(app_screenshot_set).to receive(:upload_screenshot).with(path: local_screenshot.path, wait_for_processing: false)
        subject.upload_screenshots([localization], screenshots_per_language)
      end
    end

    context 'when localization has the exact same screenshot uploaded already' do
      it 'should skip that screenshot' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot',
                                source_file_checksum: 'checksum')
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        local_screenshot = double('Deliver::AppScreenshot',
                                  path: '/path/to/screenshot',
                                  language: 'en-US',
                                  device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        screenshots_per_language = { 'en-US' => [local_screenshot] }
        allow(described_class).to receive(:calculate_checksum).with(local_screenshot.path).and_return('checksum')

        expect(app_screenshot_set).to_not(receive(:upload_screenshot))
        subject.upload_screenshots([localization], screenshots_per_language)
      end
    end

    context 'when there are 11 screenshots to upload locally' do
      it 'should skip 11th screenshot' do
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        local_screenshot = double('Deliver::AppScreenshot',
                                  path: '/path/to/screenshot',
                                  language: 'en-US',
                                  device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        screenshots_per_language = { 'en-US' => Array.new(11, local_screenshot) }
        allow(described_class).to receive(:calculate_checksum).with(local_screenshot.path).and_return('checksum')

        expect(app_screenshot_set).to receive(:upload_screenshot).exactly(10).times
        subject.upload_screenshots([localization], screenshots_per_language)
      end
    end

    context 'when localization has 10 screenshots uploaded already and try uploading another new screenshot' do
      it 'should skip 11th screenshot' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot',
                                source_file_checksum: 'checksum')
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: Array.new(10, app_screenshot))
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        uploaded_local_screenshot = double('Deliver::AppScreenshot',
                                           path: '/path/to/screenshot',
                                           language: 'en-US',
                                           device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        new_local_screenshot = double('Deliver::AppScreenshot',
                                      path: '/path/to/new_screenshot',
                                      language: 'en-US',
                                      device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        screenshots_per_language = { 'en-US' => [*Array.new(10, uploaded_local_screenshot), new_local_screenshot] }
        allow(described_class).to receive(:calculate_checksum).with(uploaded_local_screenshot.path).and_return('checksum')
        allow(described_class).to receive(:calculate_checksum).with(new_local_screenshot.path).and_return('another_checksum')

        expect(app_screenshot_set).to_not(receive(:upload_screenshot))
        subject.upload_screenshots([localization], screenshots_per_language)
      end
    end
  end

  describe '#wait_for_complete' do
    context 'when all the screenshots are COMPLETE state' do
      it 'should finish without sleep' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot',
                                asset_delivery_state: { 'state' => 'COMPLETE' })
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        iterator = Deliver::AppScreenshotIterator.new([localization])

        expect(::Kernel).to_not(receive(:sleep))
        expect(subject.wait_for_complete(iterator)).to eq('COMPLETE' => 1)
      end
    end

    context 'when all the screenshots are UPLOAD_COMPLETE state initially and then become COMPLETE state' do
      it 'should finish waiting with sleep' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot')
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        iterator = Deliver::AppScreenshotIterator.new([localization])

        expect_any_instance_of(Object).to receive(:sleep).with(kind_of(Numeric)).once
        expect(app_screenshot).to receive(:asset_delivery_state).and_return({ 'state' => 'UPLOAD_COMPLETE' }, { 'state' => 'COMPLETE' })
        expect(subject.wait_for_complete(iterator)).to eq('COMPLETE' => 1)
      end
    end
  end

  describe '#retry_upload_screenshots_if_needed' do
    context 'when all the screenshots are COMPLETE state' do
      it 'should not retry upload_screenshots' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot')
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        iterator = Deliver::AppScreenshotIterator.new([localization])
        states = { 'FAILD' => 0, 'COMPLETE' => 1 }

        expect(subject).to_not(receive(:upload_screenshots))
        subject.retry_upload_screenshots_if_needed(iterator, states, 1, 1, [], [])
      end
    end

    context 'when one of the screenshots is FAILD state and tries reamins non zero' do
      it 'should retry upload_screenshots' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot', 'complete?' => false)
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        iterator = Deliver::AppScreenshotIterator.new([localization])
        states = { 'FAILED' => 1, 'COMPLETE' => 0 }

        expect(subject).to receive(:upload_screenshots).with(any_args)
        expect(app_screenshot).to receive(:delete!)
        subject.retry_upload_screenshots_if_needed(iterator, states, 1, 1, [], [])
      end
    end

    context 'when given number_of_screenshots doesn\'t match numbers in states in total' do
      it 'should retry upload_screenshots' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot', 'complete?' => true)
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        iterator = Deliver::AppScreenshotIterator.new([localization])
        states = { 'FAILED' => 1, 'COMPLETE' => 0 }

        expect(subject).to receive(:upload_screenshots).with(any_args)
        subject.retry_upload_screenshots_if_needed(iterator, states, 999, 1, [], [])
      end
    end

    context 'when retry count left is 0' do
      it 'should raise error' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot', 'complete?' => true)
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        iterator = Deliver::AppScreenshotIterator.new([localization])
        states = { 'FAILED' => 1, 'COMPLETE' => 0 }

        expect(subject).to_not(receive(:upload_screenshots).with(any_args))
        expect(UI).to receive(:user_error!)
        subject.retry_upload_screenshots_if_needed(iterator, states, 1, 0, [], [])
      end
    end
  end

  describe '#sort_screenshots' do
    def make_app_screenshot(id: nil, file_name: nil, is_complete: true)
      app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot', id: id, file_name: file_name)
      # `complete?` needed to be mocked by this way since Rubocop using 2.0 parser can't handle `{ 'complete?':  false }` format
      allow(app_screenshot).to receive(:complete?).and_return(is_complete)
      app_screenshot
    end

    context 'when localization has screenshots uploaded in wrong order' do
      it 'should reoder screenshots' do
        app_screenshot1 = make_app_screenshot(id: '1', file_name: '6.5_1.jpg')
        app_screenshot2 = make_app_screenshot(id: '2', file_name: '6.5_2.jpg')
        app_screenshot3 = make_app_screenshot(id: '3', file_name: '6.5_3.jpg')
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot3, app_screenshot2, app_screenshot1])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        expect(app_screenshot_set).to receive(:reorder_screenshots).with(app_screenshot_ids: ['1', '2', '3'])
        described_class.new.sort_screenshots([localization])
      end
    end
  end
end
