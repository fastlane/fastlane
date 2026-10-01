require 'fastlane_core'
require 'digest/md5'
require 'naturally'

require_relative 'app_screenshot'
require_relative 'app_screenshot_iterator'
require_relative 'loader'
require_relative 'screenshot_comparable'

module Deliver
  class SyncScreenshots
    DeleteScreenshotJob = Struct.new(:app_screenshot, :locale)
    UploadScreenshotJob = Struct.new(:app_screenshot_set, :path)

    class UploadResult
      attr_reader :asset_delivery_state_counts, :failing_screenshots

      def initialize(asset_delivery_state_counts:, failing_screenshots:)
        @asset_delivery_state_counts = asset_delivery_state_counts
        @failing_screenshots = failing_screenshots
      end

      def processing?
        @asset_delivery_state_counts.fetch('UPLOAD_COMPLETE', 0) > 0
      end

      def screenshot_count
        @asset_delivery_state_counts.fetch('COMPLETE', 0)
      end
    end

    def initialize(app:, platform:)
      @app = app
      @platform = platform
    end

    def sync_from_path(screenshots_path)
      # load local screenshots
      screenshots = Deliver::Loader.load_app_screenshots(screenshots_path, true)
      sync(screenshots)
    end

    def sync(screenshots)
      UI.important('This is currently a beta feature in fastlane. This may cause some errors on your environment.')

      unless FastlaneCore::Feature.enabled?('FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS')
        UI.user_error!('Please set a value to "FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS" environment variable ' \
                       'if you acknowledge the risk and try this out.')
      end

      UI.important("Will begin uploading snapshots for '#{version.version_string}' on App Store Connect")

      # enable localizations that will be used
      screenshots_per_language = screenshots.group_by(&:language)
      enable_localizations(screenshots_per_language.keys)

      # create iterator
      localizations = fetch_localizations
      iterator = Deliver::AppScreenshotIterator.new(localizations)

      # sync local screenshots with remote settings by deleting and uploading
      UI.message("Starting with the upload of screenshots...")
      replace_screenshots(iterator, screenshots)

      # ensure screenshots within screenshot sets are sorted in right order
      sort_screenshots(iterator)

      UI.important('Screenshots are synced successfully!')
    end

    def enable_localizations(locales)
      localizations = fetch_localizations
      locales_to_enable = locales - localizations.map(&:locale)
      Helper.show_loading_indicator("Activating localizations for #{locales_to_enable.join(', ')}...")
      locales_to_enable.each do |locale|
        version.create_app_store_version_localization(attributes: { locale: locale })
      end
      Helper.hide_loading_indicator
    end

    def replace_screenshots(iterator, screenshots, retries = 3)
      # delete and upload screenshots to get App Store Connect in sync
      do_replace_screenshots(iterator, screenshots, create_delete_worker, create_upload_worker)

      # wait for screenshots to be processed on App Store Connect end and
      # ensure the number of uploaded screenshots matches the one in local
      result = wait_for_complete(iterator)
      return if !result.processing? && result.screenshot_count == screenshots.count

      if retries.zero?
        UI.crash!("Retried uploading screenshots #{retries} but there are still failures of processing screenshots." \
                  "Check App Store Connect console to work out which screenshots processed unsuccessfully.")
      end

      # retry with deleting failing screenshots
      result.failing_screenshots.each(&:delete!)
      replace_screenshots(iterator, screenshots, retries - 1)
    end

    # This is a testable method that focuses on figuring out what to update
    def do_replace_screenshots(iterator, screenshots, delete_worker, upload_worker)
      remote_screenshots = iterator.each_app_screenshot.map do |localization, app_screenshot_set, app_screenshot|
        ScreenshotComparable.create_from_remote(app_screenshot: app_screenshot, locale: localization.locale)
      end

      local_screenshots = iterator.each_local_screenshot(screenshots.group_by(&:language)).map do |localization, app_screenshot_set, screenshot, index|
        if index >= 10
          UI.user_error!("Found #{localization.locale} has more than 10 screenshots for #{app_screenshot_set.screenshot_display_type}. "\
                         "Make sure contains only necessary screenshots.")
        end
        ScreenshotComparable.create_from_local(screenshot: screenshot, app_screenshot_set: app_screenshot_set)
      end

      # Thanks to `Array#-` API and `ScreenshotComparable`, working out diffs between local screenshot directory and App Store Connect
      # is as easy as you can see below. The former one finds what is missing in local and the latter one is visa versa.
      screenshots_to_delete = remote_screenshots - local_screenshots
      screenshots_to_upload = local_screenshots - remote_screenshots

      delete_jobs = screenshots_to_delete.map { |x| DeleteScreenshotJob.new(x.context[:app_screenshot], x.context[:locale]) }
      delete_worker.batch_enqueue(delete_jobs)
      delete_worker.start

      upload_jobs = screenshots_to_upload.map { |x| UploadScreenshotJob.new(x.context[:app_screenshot_set], x.context[:screenshot].path) }
      upload_worker.batch_enqueue(upload_jobs)
      upload_worker.start
    end

    def wait_for_complete(iterator)
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

        result = UploadResult.new(asset_delivery_state_counts: state_counts, failing_screenshots: failing_screenshots)
        return result unless result.processing?

        # sleep with exponential backoff
        interval = 5 + (2**retry_count)
        UI.message("There are still incomplete screenshots. Will check the states again in #{interval} secs - #{state_counts}")
        sleep(interval)
        retry_count += 1
      end
    ensure
      Helper.hide_loading_indicator
    end

    def sort_screenshots(iterator)
      Helper.show_loading_indicator("Sorting screenshots uploaded...")
      sort_worker = create_sort_worker
      sort_worker.batch_enqueue(iterator.each_app_screenshot_set.to_a.map { |_, set| set })
      sort_worker.start
      Helper.hide_loading_indicator
    end

    private

    def version
      @version ||= @app.get_edit_app_store_version(platform: @platform)
    end

    def fetch_localizations
      version.get_app_store_version_localizations
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

    def create_sort_worker
      FastlaneCore::QueueWorker.new do |app_screenshot_set|
        original_ids = app_screenshot_set.app_screenshots.map(&:id)
        sorted_ids = Naturally.sort(app_screenshot_set.app_screenshots, by: :file_name).map(&:id)
        if original_ids != sorted_ids
          app_screenshot_set.reorder_screenshots(app_screenshot_ids: sorted_ids)
        end
      end
    end
  end
end
