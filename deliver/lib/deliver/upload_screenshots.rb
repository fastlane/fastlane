require 'fastlane_core'
require 'spaceship/tunes/tunes'
require 'digest/md5'

require_relative 'app_screenshot'
require_relative 'module'
require_relative 'loader'
require_relative 'app_screenshot_iterator'

module Deliver
  # upload screenshots to App Store Connect
  class UploadScreenshots
    DeleteScreenshotSetJob = Struct.new(:app_screenshot_set, :localization)
    UploadScreenshotJob = Struct.new(:app_screenshot_set, :path)

    def upload(options, screenshots)
      return if options[:skip_screenshots]
      return if options[:edit_live]

      app = Deliver.cache[:app]

      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])
      version = app.get_edit_app_store_version(platform: platform)
      UI.user_error!("Could not find a version to edit for app '#{app.name}' for '#{platform}'") unless version

      UI.important("Will begin uploading snapshots for '#{version.version_string}' on App Store Connect")

      UI.message("Starting with the upload of screenshots...")
      screenshots_per_language = screenshots.group_by(&:language)

      localizations = version.get_app_store_version_localizations

      if options[:overwrite_screenshots]
        delete_screenshots(localizations, screenshots_per_language)
      end

      # Finding languages to enable
      languages = screenshots_per_language.keys
      locales_to_enable = languages - localizations.map(&:locale)

      if locales_to_enable.count > 0
        lng_text = "language"
        lng_text += "s" if locales_to_enable.count != 1
        Helper.show_loading_indicator("Activating #{lng_text} #{locales_to_enable.join(', ')}...")

        locales_to_enable.each do |locale|
          version.create_app_store_version_localization(attributes: {
            locale: locale
          })
        end

        Helper.hide_loading_indicator

        # Refresh version localizations
        localizations = version.get_app_store_version_localizations
      end

      upload_screenshots(localizations, screenshots_per_language, options[:screenshot_processing_timeout])

      Helper.show_loading_indicator("Sorting screenshots uploaded...")
      sort_screenshots(localizations)
      Helper.hide_loading_indicator

      UI.success("Successfully uploaded screenshots to App Store Connect")
    end

    def delete_screenshots(localizations, screenshots_per_language, tries: 5)
      tries -= 1

      worker = FastlaneCore::QueueWorker.new do |job|
        start_time = Time.now
        target = "#{job.localization.locale} #{job.app_screenshot_set.screenshot_display_type}"
        begin
          UI.verbose("Deleting '#{target}'")
          job.app_screenshot_set.delete!
          UI.message("Deleted '#{target}' -  (#{Time.now - start_time} secs)")
        rescue => error
          UI.error("Failed to delete screenshot #{target} - (#{Time.now - start_time} secs)")
          UI.error(error.message)
        end
      end

      iterator = AppScreenshotIterator.new(localizations)
      iterator.each_app_screenshot_set do |localization, app_screenshot_set|
        # Only delete screenshots if trying to upload
        next unless screenshots_per_language.keys.include?(localization.locale)

        UI.verbose("Queued delete screenshot set job for #{localization.locale} #{app_screenshot_set.screenshot_display_type}")
        worker.enqueue(DeleteScreenshotSetJob.new(app_screenshot_set, localization))
      end

      worker.start

      # Verify all screenshots have been deleted
      # Sometimes API requests will fail but screenshots will still be deleted
      count = iterator.each_app_screenshot_set
                      .select { |localization, _| screenshots_per_language.keys.include?(localization.locale) }
                      .map { |_, app_screenshot_set| app_screenshot_set }
                      .reduce(0) { |sum, app_screenshot_set| sum + app_screenshot_set.app_screenshots.size }

      UI.important("Number of screenshots not deleted: #{count}")
      if count > 0
        if tries.zero?
          UI.user_error!("Failed verification of all screenshots deleted... #{count} screenshot(s) still exist")
        else
          UI.error("Failed to delete all screenshots... Tries remaining: #{tries}")
          delete_screenshots(localizations, screenshots_per_language, tries: tries)
        end
      else
        UI.message("Successfully deleted all screenshots")
      end
    end

    def upload_screenshots(localizations, screenshots_per_language, timeout_seconds, tries: 5)
      tries -= 1

      # Upload screenshots
      worker = FastlaneCore::QueueWorker.new do |job|
        begin
          UI.verbose("Uploading '#{job.path}'...")
          start_time = Time.now
          job.app_screenshot_set.upload_screenshot(path: job.path, wait_for_processing: false)
          UI.message("Uploaded '#{job.path}'... (#{Time.now - start_time} secs)")
        rescue => error
          UI.error(error)
        end
      end

      # Each app_screenshot_set can have only 10 images
      number_of_screenshots_per_set = {}
      total_number_of_screenshots = 0

      iterator = AppScreenshotIterator.new(localizations)
      iterator.each_local_screenshot(screenshots_per_language) do |localization, app_screenshot_set, screenshot|
        # Initialize counter on each app screenshot set
        number_of_screenshots_per_set[app_screenshot_set] ||= (app_screenshot_set.app_screenshots || []).count

        if number_of_screenshots_per_set[app_screenshot_set] >= 10
          UI.error("Too many screenshots found for device '#{screenshot.display_type}' in '#{screenshot.language}', skipping this one (#{screenshot.path})")
          next
        end

        checksum = UploadScreenshots.calculate_checksum(screenshot.path)
        duplicate = (app_screenshot_set.app_screenshots || []).any? { |s| s.source_file_checksum == checksum }

        # Enqueue uploading job if it's not duplicated otherwise screenshot will be skipped
        if duplicate
          UI.message("Previous uploaded. Skipping '#{screenshot.path}'...")
        else
          UI.verbose("Queued upload screenshot job for #{localization.locale} #{app_screenshot_set.screenshot_display_type} #{screenshot.path}")
          worker.enqueue(UploadScreenshotJob.new(app_screenshot_set, screenshot.path))
          number_of_screenshots_per_set[app_screenshot_set] += 1
        end

        total_number_of_screenshots += 1
      end

      worker.start

      UI.verbose('Uploading jobs are completed')

      Helper.show_loading_indicator("Waiting for all the screenshots to finish being processed...")
      states = wait_for_complete(iterator, timeout_seconds)
      Helper.hide_loading_indicator
      retry_upload_screenshots_if_needed(iterator, states, total_number_of_screenshots, tries, timeout_seconds, localizations, screenshots_per_language)

      UI.message("Successfully uploaded all screenshots")
    end

    # Verify all screenshots have been processed
    def wait_for_complete(iterator, timeout_seconds)
      start_time = Time.now
      loop do
        states = iterator.each_app_screenshot.map { |_, _, app_screenshot| app_screenshot }.each_with_object({}) do |app_screenshot, hash|
          state = app_screenshot.asset_delivery_state['state']
          hash[state] ||= 0
          hash[state] += 1
        end

        is_processing = states.fetch('UPLOAD_COMPLETE', 0) > 0
        return states unless is_processing

        if Time.now - start_time > timeout_seconds
          UI.important("Screenshot upload reached the timeout limit of #{timeout_seconds} seconds. We'll now retry uploading the screenshots that couldn't be uploaded in time.")
          return states
        end

        UI.verbose("There are still incomplete screenshots - #{states}")
        sleep(5)
      end
    end

    # Verify all screenshots states on App Store Connect are okay
    def retry_upload_screenshots_if_needed(iterator, states, number_of_screenshots, tries, timeout_seconds, localizations, screenshots_per_language)
      is_failure = states.fetch("FAILED", 0) > 0
      is_processing = states.fetch('UPLOAD_COMPLETE', 0) > 0
      is_missing_screenshot = !screenshots_per_language.empty? && !verify_local_screenshots_are_uploaded(iterator, screenshots_per_language)
      return unless is_failure || is_missing_screenshot || is_processing

      if tries.zero?
        iterator.each_app_screenshot.select { |_, _, app_screenshot| app_screenshot.error? }.each do |localization, _, app_screenshot|
          UI.error("#{app_screenshot.file_name} for #{localization.locale} has error(s) - #{app_screenshot.error_messages.join(', ')}")
        end
        incomplete_screenshot_count = states.reject { |k, v| k == 'COMPLETE' }.reduce(0) { |sum, (k, v)| sum + v }
        UI.user_error!("Failed verification of all screenshots uploaded... #{incomplete_screenshot_count} incomplete screenshot(s) still exist")
      else
        UI.error("Failed to upload all screenshots... Tries remaining: #{tries}")
        # Delete bad entries before retry
        iterator.each_app_screenshot do |_, _, app_screenshot|
          app_screenshot.delete! unless app_screenshot.complete?
        end
        upload_screenshots(localizations, screenshots_per_language, timeout_seconds, tries: tries)
      end
    end

    # Return `true` if all the local screenshots are uploaded to App Store Connect
    def verify_local_screenshots_are_uploaded(iterator, screenshots_per_language)
      # Check if local screenshots' checksum exist on App Store Connect
      checksum_to_app_screenshot = iterator.each_app_screenshot.map { |_, _, app_screenshot| [app_screenshot.source_file_checksum, app_screenshot] }.to_h

      number_of_screenshots_per_set = {}
      missing_local_screenshots = iterator.each_local_screenshot(screenshots_per_language).select do |_, app_screenshot_set, local_screenshot|
        number_of_screenshots_per_set[app_screenshot_set] ||= (app_screenshot_set.app_screenshots || []).count
        checksum = UploadScreenshots.calculate_checksum(local_screenshot.path)

        if checksum_to_app_screenshot[checksum]
          next(false)
        else
          is_missing = number_of_screenshots_per_set[app_screenshot_set] < 10 # if it's more than 10, it's skipped
          number_of_screenshots_per_set[app_screenshot_set] += 1
          next(is_missing)
        end
      end

      missing_local_screenshots.each do |_, _, screenshot|
        UI.error("#{screenshot.path} is missing on App Store Connect.")
      end

      missing_local_screenshots.empty?
    end

    def sort_screenshots(localizations)
      require 'naturally'
      iterator = AppScreenshotIterator.new(localizations)

      # Re-order screenshots within app_screenshot_set
      worker = FastlaneCore::QueueWorker.new do |app_screenshot_set|
        original_ids = app_screenshot_set.app_screenshots.map(&:id)
        sorted_ids = Naturally.sort(app_screenshot_set.app_screenshots, by: :file_name).map(&:id)
        if original_ids != sorted_ids
          app_screenshot_set.reorder_screenshots(app_screenshot_ids: sorted_ids)
        end
      end

      iterator.each_app_screenshot_set do |_, app_screenshot_set|
        worker.enqueue(app_screenshot_set)
      end

      worker.start
    end

    def collect_screenshots(options)
      return [] if options[:skip_screenshots]
      return Loader.load_app_screenshots(options[:screenshots_path], options[:ignore_language_directory_validation])
    end

    # helper method so Spaceship::Tunes.client.available_languages is easier to test
    def self.available_languages
      # 2020-08-24 - Available locales are not available as an endpoint in App Store Connect
      # Update with Spaceship::Tunes.client.available_languages.sort (as long as endpoint is available)
      Deliver::Languages::ALL_LANGUAGES
    end

    # helper method to mock this step in tests
    def self.calculate_checksum(path)
      bytes = File.binread(path)
      Digest::MD5.hexdigest(bytes)
    end
  end
end
