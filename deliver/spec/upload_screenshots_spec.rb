require 'deliver/upload_screenshots'
require 'fakefs/spec_helpers'

describe Deliver::UploadScreenshots do
  describe '#delete_screenshots' do
    context 'when localization has a screenshot' do
      it 'should delete screenshots by screenshot_sets that AppScreenshotIterator gives' do
        # return empty by `app_screenshots` as `each_app_screenshot_set` mocked needs it empty
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        screenshots_per_language = { 'en-US' => [] }

        # emulate Deliver::AppScreenshotIterator#each_app_screenshot_set's two behaviors with or without given block
        allow_any_instance_of(Deliver::AppScreenshotIterator).to receive(:each_app_screenshot_set) do |&args|
          next([[localization, app_screenshot_set]]) unless args
          args.call(localization, app_screenshot_set)
        end

        expect(app_screenshot_set).to receive(:delete!)
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

        # emulate Deliver::AppScreenshotIterator#each_app_screenshot_set's two behaviors with or without given block
        allow_any_instance_of(Deliver::AppScreenshotIterator).to receive(:each_app_screenshot_set) do |&args|
          next([[localization, app_screenshot_set]]) unless args
          args.call(localization, app_screenshot_set)
        end

        # Return a screenshot once to fail validation and then return empty next time to pass it
        allow(app_screenshot_set).to receive(:app_screenshots).exactly(2).times.and_return([app_screenshot], [])

        # Try `delete!` twice by retry
        expect(app_screenshot_set).to receive(:delete!).twice
        described_class.new.delete_screenshots([localization], screenshots_per_language)
      end
    end
  end

  describe '#upload_screenshots' do
    subject { described_class.new }

    before do
      # mock these methods partially to simplify test cases
      allow(subject).to receive(:wait_for_complete)
      allow(subject).to receive(:retry_upload_screenshots_if_needed)
    end

    context 'when localization has no screenshot uploaded' do
      context 'with nil' do
        it 'should upload screenshots with app_screenshot_set' do
          app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                      screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                      app_screenshots: nil)
          localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                                locale: 'en-US',
                                get_app_screenshot_sets: [app_screenshot_set])
          local_screenshot = double('Deliver::AppScreenshot',
                                    path: '/path/to/screenshot',
                                    language: 'en-US',
                                    device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
          screenshots_per_language = { 'en-US' => [local_screenshot] }

          allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
          allow(described_class).to receive(:calculate_checksum).and_return('checksum')

          expect(app_screenshot_set).to receive(:upload_screenshot).with(path: local_screenshot.path, wait_for_processing: false)
          subject.upload_screenshots([localization], screenshots_per_language)
        end
      end

      context 'with empty array' do
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

          allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
          expect(app_screenshot_set).to receive(:upload_screenshot).with(path: local_screenshot.path, wait_for_processing: false)
          subject.upload_screenshots([localization], screenshots_per_language)
        end
      end
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

        allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
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

        allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
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

        allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
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

        allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
        expect(app_screenshot_set).to_not(receive(:upload_screenshot))
        subject.upload_screenshots([localization], screenshots_per_language)
      end
    end

    context 'when localization has 10 screenshots uploaded already and try inserting another new screenshot to the top of the list' do
      it 'should skip new screenshot' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot',
                                source_file_checksum: 'checksum')
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: Array.new(10, app_screenshot))
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        uploaded_local_screenshot = double('Deliver::AppScreenshot',
                                           path: 'screenshot.jpg',
                                           language: 'en-US',
                                           device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        new_local_screenshot = double('Deliver::AppScreenshot',
                                      path: '0_screenshot.jpg',
                                      language: 'en-US',
                                      device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)

        # The new screenshot appears prior to others in the iterator
        screenshots_per_language = { 'en-US' => [new_local_screenshot, *Array.new(10, uploaded_local_screenshot)] }
        allow(described_class).to receive(:calculate_checksum).with(uploaded_local_screenshot.path).and_return('checksum')
        allow(described_class).to receive(:calculate_checksum).with(new_local_screenshot.path).and_return('another_checksum')

        allow(FastlaneCore::Helper).to receive(:show_loading_indicator).and_return(true)
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
        subject.retry_upload_screenshots_if_needed(iterator, states, 1, 1, [], {})
      end
    end

    context 'when one of the screenshots is FAILD state and tries remains non zero' do
      it 'should retry upload_screenshots' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot', 'complete?' => false, 'error?' => true)
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
        subject.retry_upload_screenshots_if_needed(iterator, states, 1, 1, [], {})
      end
    end

    context 'when given number_of_screenshots doesn\'t match numbers in states in total' do
      it 'should retry upload_screenshots' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot', 'complete?' => true, 'error?' => false)
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        iterator = Deliver::AppScreenshotIterator.new([localization])
        states = { 'FAILED' => 1, 'COMPLETE' => 0 }

        expect(subject).to receive(:upload_screenshots).with(any_args)
        subject.retry_upload_screenshots_if_needed(iterator, states, 999, 1, [], {})
      end
    end

    context 'when retry count left is 0' do
      it 'should raise error' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot',
                                'complete?' => false,
                                'error?' => true,
                                file_name: '5.5_1.jpg',
                                error_messages: ['error_message'])
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
        subject.retry_upload_screenshots_if_needed(iterator, states, 1, 0, [], {})
      end
    end

    context 'when there is nothing to upload locally but some exist on App Store Connect' do
      let(:number_of_screenshots) { 0 }     # This is 0 since no image exists locally
      let(:screenshots_per_language) { {} } # This is empty due to the same reason

      it 'should just finish' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot', 'complete?' => true)
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        iterator = Deliver::AppScreenshotIterator.new([localization])
        states = { 'COMPLETE' => 1 }

        expect(subject).to_not(receive(:upload_screenshots).with(any_args))
        expect(UI).to_not(receive(:user_error!))
        subject.retry_upload_screenshots_if_needed(iterator, states, number_of_screenshots, 0, [], screenshots_per_language)
      end
    end
  end

  describe '#verify_local_screenshots_are_uploaded' do
    context 'when checksums for local screenshots all exist on App Store Connect' do
      it 'should return true' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot', source_file_checksum: 'checksum')
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        iterator = Deliver::AppScreenshotIterator.new([localization])
        local_screenshot = double('Deliver::AppScreenshot',
                                  path: '/path/to/new_screenshot',
                                  language: 'en-US',
                                  device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        screenshots_per_language = { 'en-US' => [local_screenshot] }

        expect(described_class).to receive(:calculate_checksum).with(local_screenshot.path).and_return('checksum')
        expect(subject.verify_local_screenshots_are_uploaded(iterator, screenshots_per_language)).to be(true)
      end
    end

    context 'when some checksums for local screenshots don\'t exist on App Store Connect' do
      it 'should return false' do
        app_screenshot = double('Spaceship::ConnectAPI::AppScreenshot', source_file_checksum: 'checksum_not_matched')
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        iterator = Deliver::AppScreenshotIterator.new([localization])
        local_screenshot = double('Deliver::AppScreenshot',
                                  path: '/path/to/new_screenshot',
                                  language: 'en-US',
                                  device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        screenshots_per_language = { 'en-US' => [local_screenshot] }

        expect(described_class).to receive(:calculate_checksum).with(local_screenshot.path).and_return('checksum')
        expect(subject.verify_local_screenshots_are_uploaded(iterator, screenshots_per_language)).to be(false)
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
      it 'should reorder screenshots' do
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

    context 'when localization has screenshots uploaded in wrong order with trailing numbers up to 10' do
      it 'should reorder screenshots' do
        app_screenshot1 = make_app_screenshot(id: '1', file_name: '6.5_1.jpg')
        app_screenshot2 = make_app_screenshot(id: '2', file_name: '6.5_2.jpg')
        app_screenshot10 = make_app_screenshot(id: '10', file_name: '6.5_10.jpg')
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55,
                                    app_screenshots: [app_screenshot10, app_screenshot2, app_screenshot1])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              locale: 'en-US',
                              get_app_screenshot_sets: [app_screenshot_set])
        expect(app_screenshot_set).to receive(:reorder_screenshots).with(app_screenshot_ids: ['1', '2', '10'])
        described_class.new.sort_screenshots([localization])
      end
    end
  end
end
