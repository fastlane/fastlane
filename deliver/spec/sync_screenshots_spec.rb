require 'deliver/sync_screenshots'
require 'fakefs/spec_helpers'
require_relative 'deliver_constants'

describe Deliver::SyncScreenshots do
  describe '#do_replace_screenshots' do
    include DeliverConstants

    subject { described_class.new(app: nil, platform: nil) }

    DisplayType = Spaceship::ConnectAPI::AppScreenshotSet::DisplayType

    before do
      # To emulate checksum calculation, return the given path as a checksum
      allow(Deliver::ScreenshotComparable).to receive(:calculate_checksum) { |path| path }
    end

    let(:en_US) { mock_app_store_version_localization }
    let(:app_screenshot_set_55) { mock_app_screenshot_set(display_type: DisplayType::APP_IPHONE_55) }
    let(:app_screenshot_set_65) { mock_app_screenshot_set(display_type: DisplayType::APP_IPHONE_65) }

    context 'ASC has nothing and going to add screenshots' do
      let(:screenshots) do
        [
          mock_screenshot(path: '5.5_1.jpg', screen_size: ScreenSize::IOS_55),
          mock_screenshot(path: '5.5_2.jpg', screen_size: ScreenSize::IOS_55),
          mock_screenshot(path: '6.5_1.jpg', screen_size: ScreenSize::IOS_65),
          mock_screenshot(path: '6.5_2.jpg', screen_size: ScreenSize::IOS_65)
        ]
      end

      let(:iterator) do
        mock_app_screenshot_iterator(
          each_app_screenshot: [
          ],
          each_local_screenshot: [
            [en_US, app_screenshot_set_55, screenshots[0], 0],
            [en_US, app_screenshot_set_55, screenshots[1], 1],
            [en_US, app_screenshot_set_65, screenshots[2], 0],
            [en_US, app_screenshot_set_65, screenshots[3], 1]
          ]
        )
      end

      it 'should enqueue upload jobs for the screenshots that do not exist on App Store Connect' do
        delete_worker = mock_queue_worker([])
        upload_worker = mock_queue_worker([Deliver::SyncScreenshots::UploadScreenshotJob.new(app_screenshot_set_55, screenshots[0].path),
                                           Deliver::SyncScreenshots::UploadScreenshotJob.new(app_screenshot_set_55, screenshots[1].path),
                                           Deliver::SyncScreenshots::UploadScreenshotJob.new(app_screenshot_set_65, screenshots[2].path),
                                           Deliver::SyncScreenshots::UploadScreenshotJob.new(app_screenshot_set_65, screenshots[3].path)])
        subject.do_replace_screenshots(iterator, screenshots, delete_worker, upload_worker)
      end
    end

    context 'ASC has a screenshot on each screenshot set and going to add another screenshot' do
      let(:screenshots) do
        [
          mock_screenshot(path: '5.5_1.jpg', screen_size: ScreenSize::IOS_55),
          mock_screenshot(path: '5.5_2.jpg', screen_size: ScreenSize::IOS_55),
          mock_screenshot(path: '6.5_1.jpg', screen_size: ScreenSize::IOS_65),
          mock_screenshot(path: '6.5_2.jpg', screen_size: ScreenSize::IOS_65)
        ]
      end

      let(:iterator) do
        mock_app_screenshot_iterator(
          each_app_screenshot: [
            [en_US, app_screenshot_set_55, mock_app_screenshot(path: '5.5_1.jpg')],
            [en_US, app_screenshot_set_65, mock_app_screenshot(path: '6.5_1.jpg')]
          ],
          each_local_screenshot: [
            [en_US, app_screenshot_set_55, screenshots[0], 0],
            [en_US, app_screenshot_set_55, screenshots[1], 1],
            [en_US, app_screenshot_set_65, screenshots[2], 0],
            [en_US, app_screenshot_set_65, screenshots[3], 1]
          ]
        )
      end

      it 'should enqueue upload jobs for the screenshots that do not exist on App Store Connect' do
        delete_worker = mock_queue_worker([])
        upload_worker = mock_queue_worker([Deliver::SyncScreenshots::UploadScreenshotJob.new(app_screenshot_set_55, screenshots[1].path),
                                           Deliver::SyncScreenshots::UploadScreenshotJob.new(app_screenshot_set_65, screenshots[3].path)])
        subject.do_replace_screenshots(iterator, screenshots, delete_worker, upload_worker)
      end
    end

    context 'ASC has screenshots but the user has nothing locally' do
      let(:screenshots) do
        []
      end

      let(:app_screenshots) do
        [
          mock_app_screenshot(path: '5.5_1.jpg'),
          mock_app_screenshot(path: '6.5_1.jpg')
        ]
      end

      let(:iterator) do
        mock_app_screenshot_iterator(
          each_app_screenshot: [
            [en_US, app_screenshot_set_55, app_screenshots[0]],
            [en_US, app_screenshot_set_65, app_screenshots[1]]
          ],
          each_local_screenshot: [
          ]
        )
      end

      it 'should enqueue delete jobs for the screenshots that do not exist on local' do
        delete_worker = mock_queue_worker([Deliver::SyncScreenshots::DeleteScreenshotJob.new(app_screenshots[0], en_US.locale),
                                           Deliver::SyncScreenshots::DeleteScreenshotJob.new(app_screenshots[1], en_US.locale)])
        upload_worker = mock_queue_worker([])
        subject.do_replace_screenshots(iterator, screenshots, delete_worker, upload_worker)
      end
    end

    context 'ASC has some screenshots and the user replaces some of them' do
      let(:app_screenshots) do
        [
          mock_app_screenshot(path: '5.5_1.jpg'),
          mock_app_screenshot(path: '5.5_2.jpg'),
          mock_app_screenshot(path: '6.5_1.jpg'),
          mock_app_screenshot(path: '6.5_2.jpg')
        ]
      end

      let(:screenshots) do
        [
          mock_screenshot(path: '5.5_1.jpg', screen_size: ScreenSize::IOS_55),
          mock_screenshot(path: '5.5_2_improved.jpg', screen_size: ScreenSize::IOS_55),
          mock_screenshot(path: '6.5_1.jpg', screen_size: ScreenSize::IOS_65),
          mock_screenshot(path: '6.5_2_improved.jpg', screen_size: ScreenSize::IOS_65)
        ]
      end

      let(:iterator) do
        mock_app_screenshot_iterator(
          each_app_screenshot: [
            [en_US, app_screenshot_set_55, app_screenshots[0]],
            [en_US, app_screenshot_set_55, app_screenshots[1]],
            [en_US, app_screenshot_set_65, app_screenshots[2]],
            [en_US, app_screenshot_set_65, app_screenshots[3]]
          ],
          each_local_screenshot: [
            [en_US, app_screenshot_set_55, screenshots[0], 0],
            [en_US, app_screenshot_set_55, screenshots[1], 1],
            [en_US, app_screenshot_set_65, screenshots[2], 0],
            [en_US, app_screenshot_set_65, screenshots[3], 1]
          ]
        )
      end

      it 'should enqueue both delete and upload jobs to keep them up-to-date' do
        delete_worker = mock_queue_worker([Deliver::SyncScreenshots::DeleteScreenshotJob.new(app_screenshots[1], en_US.locale),
                                           Deliver::SyncScreenshots::DeleteScreenshotJob.new(app_screenshots[3], en_US.locale)])
        upload_worker = mock_queue_worker([Deliver::SyncScreenshots::UploadScreenshotJob.new(app_screenshot_set_55, screenshots[1].path),
                                           Deliver::SyncScreenshots::UploadScreenshotJob.new(app_screenshot_set_65, screenshots[3].path)])
        subject.do_replace_screenshots(iterator, screenshots, delete_worker, upload_worker)
      end
    end

    def mock_app_screenshot_iterator(each_app_screenshot: [], each_local_screenshot: [])
      iterator = double('Deliver::AppScreenshotIterator')

      enumerator1 = each_app_screenshot.to_enum
      allow(iterator).to receive(:each_app_screenshot) do |&arg|
        next(enumerator1.to_a) unless arg
        arg.call(*enumerator1.next)
      end

      enumerator2 = each_local_screenshot.to_enum
      allow(iterator).to receive(:each_local_screenshot) do |&arg|
        next(enumerator2.to_a) unless arg
        arg.call(*enumerator2.next)
      end

      iterator
    end

    def mock_queue_worker(enqueued_jobs)
      queue_worker = double('FastlaneCore::QueueWorker')
      expect(queue_worker).to receive(:batch_enqueue).with(enqueued_jobs)
      expect(queue_worker).to receive(:start)
      queue_worker
    end

    def mock_app_screenshot(path: '/path/to/screenshot')
      screenshot = double(
        'Spaceship::ConnectAPI::AppScreenshot',
        file_name: path,
        source_file_checksum: path # To match the behavior of stubbing checksum calculation, use given path as a checksum
      )
      allow(screenshot).to receive(:kind_of?).with(Spaceship::ConnectAPI::AppScreenshot).and_return(true)
      screenshot
    end

    def mock_screenshot(path: '/path/to/screenshot', language: 'en-US', screen_size: Deliver::AppScreenshot::ScreenSize::IOS_55)
      screenshot = double(
        'Deliver::AppScreenshot',
        path: path,
        language: language,
        device_type: screen_size
      )
      allow(screenshot).to receive(:kind_of?).with(Deliver::AppScreenshot).and_return(true)
      screenshot
    end

    def mock_app_store_version_localization(locale: 'en-US', app_screenshot_sets: [])
      double(
        'Spaceship::ConnectAPI::AppStoreVersionLocalization',
        locale: locale,
        get_app_screenshot_sets: app_screenshot_sets
      )
    end

    def mock_app_screenshot_set(display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55, app_screenshots: [])
      app_screenshot_set = double(
        'Spaceship::ConnectAPI::AppScreenshotSet',
        screenshot_display_type: display_type,
        app_screenshots: app_screenshots
      )
      allow(app_screenshot_set).to receive(:kind_of?).with(Spaceship::ConnectAPI::AppScreenshotSet).and_return(true)
      app_screenshot_set
    end
  end
end
