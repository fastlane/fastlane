require 'spaceship/tunes/tunes'

require_relative 'module'
require_relative 'download_screenshots'
require_relative 'upload_metadata'

module Deliver
  class Setup
    attr_accessor :is_swift

    def run(options, is_swift: false)
      containing = Helper.fastlane_enabled_folder_path
      self.is_swift = is_swift

      if is_swift
        file_path = File.join(containing, 'Deliverfile.swift')
      else
        file_path = File.join(containing, 'Deliverfile')
      end
      data = generate_deliver_file(containing, options)
      setup_deliver(file_path, data, containing, options)
    end

    def setup_deliver(file_path, data, deliver_path, options)
      File.write(file_path, data)

      screenshots_path = options[:screenshots_path] || File.join(deliver_path, 'screenshots')
      unless options[:skip_screenshots]
        download_screenshots(screenshots_path, options)

        # Add a README to the screenshots folder
        FileUtils.mkdir_p(screenshots_path) # just in case the fetching didn't work
        File.write(File.join(screenshots_path, 'README.txt'), File.read("#{Deliver::ROOT}/lib/assets/ScreenshotsHelp"))
      end

      UI.success("Successfully created new Deliverfile at path '#{file_path}'")
    end

    # This method takes care of creating a new 'deliver' folder, containing the app metadata
    # and screenshots folders
    def generate_deliver_file(deliver_path, options)
      v = options[:app].latest_version
      metadata_path = options[:metadata_path] || File.join(deliver_path, 'metadata')
      generate_metadata_files(v, metadata_path)

      # Generate the final Deliverfile here
      return File.read(deliverfile_path)
    end

    def deliverfile_path
      if self.is_swift
        return "#{Deliver::ROOT}/lib/assets/DeliverfileDefault.swift"
      else
        return "#{Deliver::ROOT}/lib/assets/DeliverfileDefault"
      end
    end

    def generate_metadata_files(v, path)
      app_details = v.application.details

      # All the localised metadata
      (UploadMetadata::LOCALISED_VERSION_VALUES + UploadMetadata::LOCALISED_APP_VALUES).each do |key|
        v.description.languages.each do |language|
          if UploadMetadata::LOCALISED_VERSION_VALUES.include?(key)
            content = v.send(key)[language].to_s
          else
            content = app_details.send(key)[language].to_s
          end
          content << "\n"
          resulting_path = File.join(path, language, "#{key}.txt")
          FileUtils.mkdir_p(File.expand_path('..', resulting_path))
          File.write(resulting_path, content)
          UI.message("Writing to '#{resulting_path}'")
        end
      end

      # All non-localised metadata
      (UploadMetadata::NON_LOCALISED_VERSION_VALUES + UploadMetadata::NON_LOCALISED_APP_VALUES).each do |key|
        if UploadMetadata::NON_LOCALISED_VERSION_VALUES.include?(key)
          content = v.send(key).to_s
        else
          content = app_details.send(key).to_s
        end
        content << "\n"
        resulting_path = File.join(path, "#{key}.txt")
        File.write(resulting_path, content)
        UI.message("Writing to '#{resulting_path}'")
      end

      # Trade Representative Contact Information
      UploadMetadata::TRADE_REPRESENTATIVE_CONTACT_INFORMATION_VALUES.each do |key, option_name|
        content = v.send(key).to_s
        content << "\n"
        base_dir = File.join(path, UploadMetadata::TRADE_REPRESENTATIVE_CONTACT_INFORMATION_DIR)
        FileUtils.mkdir_p(base_dir)
        resulting_path = File.join(base_dir, "#{option_name}.txt")
        File.write(resulting_path, content)
        UI.message("Writing to '#{resulting_path}'")
      end

      # Review information
      UploadMetadata::REVIEW_INFORMATION_VALUES.each do |key, option_name|
        content = v.send(key).to_s
        content << "\n"
        base_dir = File.join(path, UploadMetadata::REVIEW_INFORMATION_DIR)
        FileUtils.mkdir_p(base_dir)
        resulting_path = File.join(base_dir, "#{option_name}.txt")
        File.write(resulting_path, content)
        UI.message("Writing to '#{resulting_path}'")
      end

      UI.success("Successfully created new configuration files.")

      # get App icon + watch icon
      if v.large_app_icon.asset_token
        app_icon_extension = File.extname(v.large_app_icon.url)
        app_icon_path = File.join(path, "app_icon#{app_icon_extension}")
        File.write(app_icon_path, open(v.large_app_icon.url).read)
        UI.success("Successfully downloaded large app icon")
      end
      if v.watch_app_icon.asset_token
        watch_app_icon_extension = File.extname(v.watch_app_icon.url)
        watch_icon_path = File.join(path, "watch_icon#{watch_app_icon_extension}")
        File.write(watch_icon_path, open(v.watch_app_icon.url).read)
        UI.success("Successfully downloaded watch icon")
      end
    end

    def download_screenshots(path, options)
      FileUtils.mkdir_p(path)
      Deliver::DownloadScreenshots.run(options, path)
    end
  end
end
