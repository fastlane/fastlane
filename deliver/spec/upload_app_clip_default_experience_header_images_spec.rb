require 'deliver/upload_app_clip_default_experience_header_images'
require 'deliver/app_clip_header_image'

describe Deliver::UploadAppClipDefaultExperienceHeaderImages do
  let(:uploader) { Deliver::UploadAppClipDefaultExperienceHeaderImages.new }

  describe '#assign_default_images' do
    let(:options) do
      {
        languages: ['en-US', 'ko', 'ja'],
        app_clip_header_images_path: '/path/to/header_images'
      }
    end

    it 'should assign default image to languages without images' do
      # Create a default image and one language-specific image
      default_image = Deliver::AppClipHeaderImage.new('/path/to/header_images/default/header.jpg', nil)
      en_image = Deliver::AppClipHeaderImage.new('/path/to/header_images/en-US/header.jpg', 'en-US')
      app_clip_header_images = [default_image, en_image]

      uploader.send(:assign_default_images, options, app_clip_header_images)

      # Should have en-US (original), ko (from default), ja (from default)
      # Default should be removed
      expect(app_clip_header_images.length).to eq(3)
      expect(app_clip_header_images.map(&:language)).to contain_exactly('en-US', 'ko', 'ja')

      # Verify ko and ja use the default image path
      ko_image = app_clip_header_images.find { |img| img.language == 'ko' }
      ja_image = app_clip_header_images.find { |img| img.language == 'ja' }
      expect(ko_image.path).to eq('/path/to/header_images/default/header.jpg')
      expect(ja_image.path).to eq('/path/to/header_images/default/header.jpg')
    end

    it 'should not assign default image to languages that already have images' do
      default_image = Deliver::AppClipHeaderImage.new('/path/to/header_images/default/header.jpg', nil)
      en_image = Deliver::AppClipHeaderImage.new('/path/to/header_images/en-US/header.jpg', 'en-US')
      ko_image = Deliver::AppClipHeaderImage.new('/path/to/header_images/ko/header.jpg', 'ko')
      ja_image = Deliver::AppClipHeaderImage.new('/path/to/header_images/ja/header.jpg', 'ja')
      app_clip_header_images = [default_image, en_image, ko_image, ja_image]

      uploader.send(:assign_default_images, options, app_clip_header_images)

      # Should keep all original images
      expect(app_clip_header_images.length).to eq(3)
      expect(app_clip_header_images.map(&:language)).to contain_exactly('en-US', 'ko', 'ja')

      # Verify each language uses its own image path
      expect(app_clip_header_images.find { |img| img.language == 'en-US' }.path).to eq('/path/to/header_images/en-US/header.jpg')
      expect(app_clip_header_images.find { |img| img.language == 'ko' }.path).to eq('/path/to/header_images/ko/header.jpg')
      expect(app_clip_header_images.find { |img| img.language == 'ja' }.path).to eq('/path/to/header_images/ja/header.jpg')
    end

    it 'should remove default image from the list after assignment' do
      default_image = Deliver::AppClipHeaderImage.new('/path/to/header_images/default/header.jpg', nil)
      en_image = Deliver::AppClipHeaderImage.new('/path/to/header_images/en-US/header.jpg', 'en-US')
      app_clip_header_images = [default_image, en_image]

      uploader.send(:assign_default_images, options, app_clip_header_images)

      # Default image should be removed
      expect(app_clip_header_images.none? { |img| img.language.nil? }).to be(true)
    end

    it 'should do nothing when there is no default folder' do
      en_image = Deliver::AppClipHeaderImage.new('/path/to/header_images/en-US/header.jpg', 'en-US')
      ko_image = Deliver::AppClipHeaderImage.new('/path/to/header_images/ko/header.jpg', 'ko')
      app_clip_header_images = [en_image, ko_image]

      original_count = app_clip_header_images.length
      uploader.send(:assign_default_images, options, app_clip_header_images)

      # Should remain unchanged
      expect(app_clip_header_images.length).to eq(original_count)
      expect(app_clip_header_images.map(&:language)).to contain_exactly('en-US', 'ko')
    end

    it 'should handle empty app_clip_header_images array' do
      app_clip_header_images = []

      uploader.send(:assign_default_images, options, app_clip_header_images)

      # Should remain empty
      expect(app_clip_header_images).to be_empty
    end

    it 'should identify default folder by path, not by nil language' do
      # Create an image from default folder
      default_image = Deliver::AppClipHeaderImage.new('/path/to/header_images/default/header.jpg', nil)
      app_clip_header_images = [default_image]

      uploader.send(:assign_default_images, options, app_clip_header_images)

      # Should create images for all languages
      expect(app_clip_header_images.length).to eq(3)
      expect(app_clip_header_images.map(&:language)).to contain_exactly('en-US', 'ko', 'ja')
    end
  end

  describe '#detect_languages' do
    it 'should detect languages from options[:languages]' do
      options = { languages: ['en-US', 'ko', 'ja'] }
      app_clip_header_images = []

      # Mock Languages.detect_languages to return the languages from options
      allow(Deliver::Languages).to receive(:detect_languages).and_return(['en-US', 'ko', 'ja'])

      languages = uploader.send(:detect_languages, options, app_clip_header_images)

      expect(languages).to contain_exactly('en-US', 'ko', 'ja')
    end

    it 'should include languages from existing header images' do
      options = { languages: ['en-US'] }
      ko_image = Deliver::AppClipHeaderImage.new('/path/ko/header.jpg', 'ko')
      ja_image = Deliver::AppClipHeaderImage.new('/path/ja/header.jpg', 'ja')
      app_clip_header_images = [ko_image, ja_image]

      allow(Deliver::Languages).to receive(:detect_languages).and_return(['en-US'])

      languages = uploader.send(:detect_languages, options, app_clip_header_images)

      expect(languages).to contain_exactly('en-US', 'ko', 'ja')
    end

    it 'should filter out nil and empty languages from header images' do
      options = { languages: ['en-US'] }
      nil_image = Deliver::AppClipHeaderImage.new('/path/default/header.jpg', nil)
      en_image = Deliver::AppClipHeaderImage.new('/path/en-US/header.jpg', 'en-US')
      app_clip_header_images = [nil_image, en_image]

      allow(Deliver::Languages).to receive(:detect_languages).and_return(['en-US'])

      languages = uploader.send(:detect_languages, options, app_clip_header_images)

      # Should not include nil
      expect(languages).to contain_exactly('en-US')
    end
  end
end
