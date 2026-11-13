require 'fastlane_core'
require 'spaceship/tunes/tunes'

require_relative 'app_screenshot'
require_relative 'module'
require_relative 'loader'
require_relative 'app_screenshot_iterator'
require_relative 'upload_screenshots'
require_relative 'screenshot_comparable'

module Deliver
  # Upload screenshots to a Custom Product Page (CPP)
  # Reuses the logic from UploadScreenshots for enqueueing, waiting, retrying, and sorting
  class UploadCustomProductPageScreenshots < UploadScreenshots
    CPPDeleteScreenshotJob = Struct.new(:app_screenshot, :locale)
    CPPUploadScreenshotJob = Struct.new(:app_screenshot_set, :path)
    def upload(options, screenshots)
      return if options[:skip_screenshots]
      return if options[:edit_live]

      app = Deliver.cache[:app]

      cpp_id = options[:custom_product_page_id]
      UI.user_error!("You must provide :custom_product_page_id to upload screenshots to a custom product page") if cpp_id.to_s.strip.empty?

      cpp = Spaceship::ConnectAPI::AppCustomProductPage.get(app_custom_product_page_id: cpp_id).first
      UI.user_error!("Could not find custom product page with id '#{cpp_id}' for app '#{app.name}'") unless cpp

      UI.important("Will begin uploading snapshots for Custom Product Page '#{cpp.name || cpp.id}' on App Store Connect")

      UI.message("Starting with the upload of screenshots for Custom Product Page...")
      screenshots_per_language = screenshots.group_by(&:language)

      # Determine target version (auto-select most recent editable)
      editable_states = %w[DRAFT PREPARE_FOR_SUBMISSION]
      versions = Spaceship::ConnectAPI::AppCustomProductPageVersion.all(app_custom_product_page_id: cpp.id)
      UI.user_error!("Custom Product Page has no versions to upload to") if versions.nil? || versions.empty?

      preferred = versions.reverse.find { |v| v.state && editable_states.include?(v.state.to_s.upcase) }
      if preferred.nil?
        states = versions.map { |v| "#{v.id}:#{(v.state || 'UNKNOWN').to_s}" }.join(', ')
        UI.user_error!("No editable version found for Custom Product Page. Versions: #{states}. Please create a new Draft in App Store Connect and try again.")
      end

      UI.message("Using Custom Product Page Version #{preferred.id} (state=#{preferred.state}) for uploads")

      localizations = preferred.get_localizations

      # Ensure CPP has localizations for all languages we’re about to sync/upload
      languages = screenshots_per_language.keys
      locales_to_enable = languages - localizations.map(&:locale)
      if locales_to_enable.count > 0
        lng_text = "language"
        lng_text += "s" if locales_to_enable.count != 1
        Helper.show_loading_indicator("Activating #{lng_text} #{locales_to_enable.join(', ')} for Custom Product Page Version #{preferred.id} (#{preferred.state})...")
        locales_to_enable.each do |locale|
          preferred.create_localization(attributes: { locale: locale })
        end
        Helper.hide_loading_indicator
        # Refresh localizations for iterator
        localizations = preferred.get_localizations
      end

      # If syncing, use diff-based replace (don’t delete entire sets)
      if options[:sync_screenshots]
        iterator = AppScreenshotIterator.new(localizations)
        sync_replace_screenshots(iterator, screenshots)
        Helper.show_loading_indicator("Sorting screenshots uploaded...")
        sort_screenshots(localizations)
        Helper.hide_loading_indicator
        UI.success("Successfully synced screenshots to Custom Product Page on App Store Connect")
        return
      end

      # Overwrite deletes whole sets for languages being uploaded
      if options[:overwrite_screenshots]
        delete_screenshots(localizations, screenshots_per_language)
      end

      upload_screenshots(localizations, screenshots_per_language, options[:screenshot_processing_timeout])

      Helper.show_loading_indicator("Sorting screenshots uploaded...")
      sort_screenshots(localizations)
      Helper.hide_loading_indicator

      UI.success("Successfully uploaded screenshots to Custom Product Page on App Store Connect")
    end

    # Diff-based replace mirroring Deliver::SyncScreenshots but scoped to CPP localizations
    def sync_replace_screenshots(iterator, screenshots, retries = 3)
      delete_worker = create_delete_worker
      upload_worker = create_upload_worker

      do_sync_replace_screenshots(iterator, screenshots, delete_worker, upload_worker)

      result = wait_for_complete_sync(iterator)
      return if !result[:processing] && result[:complete] == screenshots.count

      if retries <= 0
        UI.crash!("Retried uploading screenshots but there are still failures. Check App Store Connect for failing screenshots.")
      end

      # Retry with deleting failing screenshots only
      (result[:failing] || []).each(&:delete!)
      sync_replace_screenshots(iterator, screenshots, retries - 1)
    end

    def do_sync_replace_screenshots(iterator, screenshots, delete_worker, upload_worker)
      remote_screenshots = iterator.each_app_screenshot.map do |localization, app_screenshot_set, app_screenshot|
        ScreenshotComparable.create_from_remote(app_screenshot: app_screenshot, locale: localization.locale)
      end

      local_screenshots = iterator.each_local_screenshot(screenshots.group_by(&:language)).map do |localization, app_screenshot_set, screenshot, index|
        if index >= 10
          UI.user_error!("Found #{localization.locale} has more than 10 screenshots for #{app_screenshot_set.screenshot_display_type}. Make sure contains only necessary screenshots.")
        end
        ScreenshotComparable.create_from_local(screenshot: screenshot, app_screenshot_set: app_screenshot_set)
      end

      screenshots_to_delete = remote_screenshots - local_screenshots
      screenshots_to_upload = local_screenshots - remote_screenshots

      delete_jobs = screenshots_to_delete.map { |x| CPPDeleteScreenshotJob.new(x.context[:app_screenshot], x.context[:locale]) }
      delete_worker.batch_enqueue(delete_jobs)
      delete_worker.start

      upload_jobs = screenshots_to_upload.map { |x| CPPUploadScreenshotJob.new(x.context[:app_screenshot_set], x.context[:screenshot].path) }
      upload_worker.batch_enqueue(upload_jobs)
      upload_worker.start
    end

    def wait_for_complete_sync(iterator)
      retry_count = 0
      Helper.show_loading_indicator("Waiting for all the screenshots processed...")
      loop do
        failing_screenshots = []
        state_counts = iterator.each_app_screenshot.map { |_, _, app_screenshot| app_screenshot }.each_with_object({}) do |app_screenshot, hash|
          state = app_screenshot.asset_delivery_state['state']
          hash[state] ||= 0
          hash[state] += 1
          failing_screenshots << app_screenshot if app_screenshot.error?
        end

        processing = state_counts.fetch('UPLOAD_COMPLETE', 0) > 0
        complete = state_counts.fetch('COMPLETE', 0)
        return { processing: processing, complete: complete, failing: failing_screenshots } unless processing

        interval = 5 + (2**retry_count)
        UI.message("There are still incomplete screenshots. Will check the states again in #{interval} secs - #{state_counts}")
        sleep(interval)
        retry_count += 1
      end
    ensure
      Helper.hide_loading_indicator
    end

    def create_upload_worker
      FastlaneCore::QueueWorker.new do |job|
        UI.verbose("Uploading '#{job.path}'...")
        start_time = Time.now
        job.app_screenshot_set.upload_screenshot(path: job.path, wait_for_processing: false)
        UI.message("Uploaded '#{job.path}'... (#{Time.now - start_time} secs)")
      end
    end

    def create_delete_worker
      FastlaneCore::QueueWorker.new do |job|
        target = "id=#{job.app_screenshot.id} #{job.locale} #{job.app_screenshot.file_name}"
        UI.verbose("Deleting '#{target}'")
        start_time = Time.now
        job.app_screenshot.delete!
        UI.message("Deleted '#{target}' -  (#{Time.now - start_time} secs)")
      end
    end
  end
end
