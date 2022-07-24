require 'deliver/app_screenshot_iterator'
require 'spaceship/connect_api/models/app_screenshot_set'

describe Deliver::AppScreenshotIterator do
  describe "#each_app_screenshot_set" do
    context 'when screenshot is empty' do
      it 'should iterates nothing' do
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization', get_app_screenshot_sets: [])
        # Test the result with enumerator returned
        expect(described_class.new([localization]).each_app_screenshot_set.to_a).to be_empty
      end
    end

    context 'when a localization has an app_screenshot_set' do
      it 'should iterates app_screenshot_set with corresponding localization' do
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet')
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization', get_app_screenshot_sets: [app_screenshot_set])
        expect(described_class.new([localization]).each_app_screenshot_set.to_a).to eq([[localization, app_screenshot_set]])
      end
    end

    context 'when localizations have multiple app_screenshot_sets' do
      it 'should iterates app_screenshot_set with corresponding localization' do
        app_screenshot_set1 = double('Spaceship::ConnectAPI::AppScreenshotSet')
        app_screenshot_set2 = double('Spaceship::ConnectAPI::AppScreenshotSet')
        app_screenshot_set3 = double('Spaceship::ConnectAPI::AppScreenshotSet')
        app_screenshot_set4 = double('Spaceship::ConnectAPI::AppScreenshotSet')
        localization1 = double('Spaceship::ConnectAPI::AppStoreVersionLocalization', get_app_screenshot_sets: [app_screenshot_set1, app_screenshot_set2])
        localization2 = double('Spaceship::ConnectAPI::AppStoreVersionLocalization', get_app_screenshot_sets: [app_screenshot_set3, app_screenshot_set4])

        expect(described_class.new([localization1, localization2]).each_app_screenshot_set.to_a)
          .to eq([[localization1, app_screenshot_set1], [localization1, app_screenshot_set2], [localization2, app_screenshot_set3], [localization2, app_screenshot_set4]])
      end
    end
  end

  describe "#each_app_screenshot" do
    context 'when screenshot is empty' do
      it 'should iterates nothing' do
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization', get_app_screenshot_sets: [])
        expect(described_class.new([localization]).each_app_screenshot.to_a).to be_empty
      end
    end

    context 'when a localization has an app_screenshot_set' do
      it 'should iterates app_screenshot_set with corresponding localization' do
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet', app_screenshots: [])
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization', get_app_screenshot_sets: [app_screenshot_set])
        expect(described_class.new([localization]).each_app_screenshot.to_a).to be_empty
      end
    end

    context 'when localizations have multiple app_screenshot_sets which have an app_screenshot' do
      it 'should iterates app_screenshot with corresponding localization and app_screenshot_set' do
        app_screenshot1 = double('Spaceship::ConnectAPI::AppScreenshot')
        app_screenshot2 = double('Spaceship::ConnectAPI::AppScreenshot')
        app_screenshot3 = double('Spaceship::ConnectAPI::AppScreenshot')
        app_screenshot4 = double('Spaceship::ConnectAPI::AppScreenshot')

        app_screenshot_set1 = double('Spaceship::ConnectAPI::AppScreenshotSet', app_screenshots: [app_screenshot1])
        app_screenshot_set2 = double('Spaceship::ConnectAPI::AppScreenshotSet', app_screenshots: [app_screenshot2])
        app_screenshot_set3 = double('Spaceship::ConnectAPI::AppScreenshotSet', app_screenshots: [app_screenshot3])
        app_screenshot_set4 = double('Spaceship::ConnectAPI::AppScreenshotSet', app_screenshots: [app_screenshot4])

        localization1 = double('Spaceship::ConnectAPI::AppStoreVersionLocalization', get_app_screenshot_sets: [app_screenshot_set1, app_screenshot_set2])
        localization2 = double('Spaceship::ConnectAPI::AppStoreVersionLocalization', get_app_screenshot_sets: [app_screenshot_set3, app_screenshot_set4])

        actual = described_class.new([localization1, localization2]).each_app_screenshot.to_a
        expect(actual).to eq([[localization1, app_screenshot_set1, app_screenshot1], [localization1, app_screenshot_set2, app_screenshot2],
                              [localization2, app_screenshot_set3, app_screenshot3], [localization2, app_screenshot_set4, app_screenshot4]])
      end
    end
  end

  describe '#each_local_screenshot' do
    context 'when screenshot is empty' do
      it 'should iterates nothing' do
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization', get_app_screenshot_sets: [], locale: ['en-US'])
        screenshots_per_language = { 'en-US' => [] }
        expect(described_class.new([localization]).each_local_screenshot(screenshots_per_language).to_a).to be_empty
      end
    end

    context 'when locale doesn\'t match the one for given local screenshots' do
      it 'should iterates nothing' do
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization', get_app_screenshot_sets: [], locale: ['fr-FR'])
        screenshots_per_language = { 'en-US' => [] }
        expect(described_class.new([localization]).each_local_screenshot(screenshots_per_language).to_a).to be_empty
      end
    end

    context 'when a localization has an app_screenshot_set' do
      it 'should iterates app_screenshot_set with corresponding localization' do
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    app_screenshots: [],
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              get_app_screenshot_sets: [app_screenshot_set],
                              locale: 'en-US')
        screenshots_per_language = { 'en-US' => [] }
        expect(described_class.new([localization]).each_local_screenshot(screenshots_per_language).to_a).to be_empty
      end
    end

    context 'when a localization does not have app_screenshot_set yet (happens with new apps)' do
      it 'should iterates app_screenshot_set with corresponding localization' do
        app_screenshot_set = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                    app_screenshots: [],
                                    screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        localization = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                              get_app_screenshot_sets: [],
                              locale: 'en-US')

        screenshot = double('Deliver::AppScreenshot', device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)

        screenshots_per_language = { 'en-US' => [screenshot] }

        expect(localization).to receive(:create_app_screenshot_set)
          .with(attributes: { screenshotDisplayType: screenshot.device_type })
          .and_return(app_screenshot_set)
        actual = described_class.new([localization]).each_local_screenshot(screenshots_per_language).to_a
        expect(actual).to eq([[localization, app_screenshot_set, screenshot, 0]])
      end
    end

    context 'when local screenshots are multiple within an app_screenshot_set' do
      it 'should give index incremented on each' do
        app_screenshot_set1 = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                     app_screenshots: [],
                                     screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        app_screenshot_set2 = double('Spaceship::ConnectAPI::AppScreenshotSet',
                                     app_screenshots: [],
                                     screenshot_display_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)

        localization1 = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                               get_app_screenshot_sets: [app_screenshot_set1],
                               locale: 'en-US')
        localization2 = double('Spaceship::ConnectAPI::AppStoreVersionLocalization',
                               get_app_screenshot_sets: [app_screenshot_set2],
                               locale: 'fr-FR')

        screenshot1 = double('Deliver::AppScreenshot', device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        screenshot2 = double('Deliver::AppScreenshot', device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        screenshot3 = double('Deliver::AppScreenshot', device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)
        screenshot4 = double('Deliver::AppScreenshot', device_type: Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_55)

        screenshots_per_language = { 'en-US' => [screenshot1, screenshot2], 'fr-FR' => [screenshot3, screenshot4] }

        actual = described_class.new([localization1, localization2]).each_local_screenshot(screenshots_per_language).to_a
        expect(actual).to eq([[localization1, app_screenshot_set1, screenshot1, 0],
                              [localization1, app_screenshot_set1, screenshot2, 1],
                              [localization2, app_screenshot_set2, screenshot3, 0],
                              [localization2, app_screenshot_set2, screenshot4, 1]])
      end
    end
  end
end
