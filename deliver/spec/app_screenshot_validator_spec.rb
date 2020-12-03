require 'deliver/app_screenshot'
require 'deliver/setup'

describe Deliver::AppScreenshotValidator do
  ScreenSize = Deliver::AppScreenshot::ScreenSize
  Error = Deliver::AppScreenshotValidator::ValidationError

  def app_screenshot_with(screen_size, format = :png, path = 'image.png', language = 'en-US')
    allow(Deliver::AppScreenshot).to receive(:calculate_screen_size).and_return(screen_size)
    allow(FastImage).to receive(:type).and_return(format)
    Deliver::AppScreenshot.new(path, language)
  end

  describe '.validate' do
    def expect_errors_to_include(screenshot, *error_types)
      errors_to_collect = []
      described_class.validate(screenshot, errors_to_collect)

      expect(errors_to_collect).to satisfy("be the same as \"#{error_types.join(', ')}\"") do |errors|
        errors.all? { |error| error_types.any? { |error_type| error.type == error_type } }
      end

      expect(errors_to_collect).not_to be_empty
    end

    def expect_no_error(screenshot)
      expect(described_class.validate(screenshot, [])).to be(true)
    end

    it 'should return true for valid screenshot' do
      expect_no_error(app_screenshot_with(ScreenSize::IOS_65, :png, 'image.png'))
      expect_no_error(app_screenshot_with(ScreenSize::IOS_65, :jpeg, 'image.jpeg'))
    end

    it 'should detect valid size screenshot' do
      expect_errors_to_include(app_screenshot_with(nil, :png, 'image.png'), Error::INVALID_SCREEN_SIZE)
    end

    it 'should detect unacceptable screen size' do
      expect_errors_to_include(app_screenshot_with('Unknown device'), Error::UNACCEPTABLE_DEVICE)
      expect_errors_to_include(app_screenshot_with(ScreenSize::IOS_61), Error::UNACCEPTABLE_DEVICE)
    end

    it 'should detect invalid file extension' do
      expect_errors_to_include(app_screenshot_with(ScreenSize::IOS_65, :gif, 'image.gif'), Error::INVALID_FILE_EXTENSION)
      expect_errors_to_include(app_screenshot_with(ScreenSize::IOS_65, :png, 'image.gif'), Error::INVALID_FILE_EXTENSION, Error::FILE_EXTENSION_MISMATCH)
    end

    it 'should detect file extension mismatch' do
      expect_errors_to_include(app_screenshot_with(ScreenSize::IOS_65, :jpeg, 'image.png'), Error::FILE_EXTENSION_MISMATCH)
      expect_errors_to_include(app_screenshot_with(ScreenSize::IOS_65, :png, 'image.jpeg'), Error::FILE_EXTENSION_MISMATCH)
    end
  end

  describe '.validate_device_type' do
    it 'should give a validation error to skip uploading screenshot' do
      errors_found = []
      described_class.validate(app_screenshot_with(ScreenSize::IOS_61), errors_found)
      error = errors_found.find { |e| e.type == Error::UNACCEPTABLE_DEVICE }
      expect(error.to_skip).to be(true)
    end
  end
end
