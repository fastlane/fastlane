module Deliver
  # This is a convinient class that enumerates app store connect's screenshots in various degrees.
  class AppScreenshotIterator
    NUMBER_OF_THREADS = Helper.test? ? 1 : [ENV.fetch("DELIVER_NUMBER_OF_THREADS", 10).to_i, 10].min

    # @param localizations [Array<Spaceship::ConnectAPI::AppStoreVersionLocalization>]
    def initialize(localizations)
      @localizations = localizations
    end

    # Iterate app_screenshot_set over localizations
    #
    # @yield [localization, app_screenshot_set]
    # @yieldparam [optional, Spaceship::ConnectAPI::AppStoreVersionLocalization] localization
    # @yieldparam [optional, Spaceship::ConnectAPI::AppStoreScreenshotSet] app_screenshot_set
    def each_app_screenshot_set(&block)
      return enum_for(__method__) unless block_given?

      # Collect app_screenshot_sets from localizations in parallel but
      # limit the number of threads working at a time with using `lazy` and `force` controls
      # to not attack App Store Connect
      results = @localizations.each_slice(NUMBER_OF_THREADS).lazy.map do |localizations|
        localizations.map do |localization|
          Thread.new do
            [localization, localization.get_app_screenshot_sets]
          end
        end
      end.flat_map do |threads|
        threads.map { |t| t.join.value }
      end.force

      results.each do |localization, app_screenshot_sets|
        app_screenshot_sets.each do |app_screenshot_set|
          yield(localization, app_screenshot_set)
        end
      end
    end

    # Iterate app_screenshot over localizations and app_screenshot_sets
    #
    # @yield [localization, app_screenshot_set, app_screenshot]
    # @yieldparam [optional, Spaceship::ConnectAPI::AppStoreVersionLocalization] localization
    # @yieldparam [optional, Spaceship::ConnectAPI::AppStoreScreenshotSet] app_screenshot_set
    # @yieldparam [optional, Spaceship::ConnectAPI::AppStoreScreenshot] app_screenshot
    def each_app_screenshot(&block)
      return enum_for(__method__) unless block_given?

      each_app_screenshot_set do |localization, app_screenshot_set|
        app_screenshot_set.app_screenshots.each do |app_screenshot|
          yield(localization, app_screenshot_set, app_screenshot)
        end
      end
    end

    # Iterate given local app_screenshot over localizations and app_screenshot_sets with index within each app_screenshot_set
    #
    # @param screenshots_per_language [Hash<String, Array<Deliver::AppScreenshot>]
    # @yield [localization, app_screenshot_set, app_screenshot, index]
    # @yieldparam [optional, Spaceship::ConnectAPI::AppStoreVersionLocalization] localization
    # @yieldparam [optional, Spaceship::ConnectAPI::AppStoreScreenshotSet] app_screenshot_set
    # @yieldparam [optional, Deliver::AppScreenshot] screenshot
    # @yieldparam [optional, Integer] index a number reperesents which position the screenshot will be
    def each_local_screenshot(screenshots_per_language, &block)
      return enum_for(__method__, screenshots_per_language) unless block_given?

      # Iterate over all the screenshots per language and display_type
      # and then enqueue them to worker one by one if it's not duplciated on App Store Connect
      screenshots_per_language.map do |language, screenshots_for_language|
        localization = @localizations.find { |l| l.locale == language }
        [localization, screenshots_for_language]
      end.reject do |localization, _|
        localization.nil?
      end.each do |localization, screenshots_for_language|
        iterate_over_screenshots_per_language(localization, screenshots_for_language, &block)
      end
    end

    private

    def iterate_over_screenshots_per_language(localization, screenshots_for_language, &block)
      app_screenshot_sets_per_display_type = localization.get_app_screenshot_sets.map { |set| [set.screenshot_display_type, set] }.to_h
      screenshots_per_display_type = screenshots_for_language.reject { |screenshot| screenshot.device_type.nil? }.group_by(&:device_type)

      screenshots_per_display_type.each do |display_type, screenshots|
        # Create AppScreenshotSet for given display_type if it doesn't exsit
        app_screenshot_set = app_screenshot_sets_per_display_type[display_type]
        app_screenshot_set ||= localization.create_app_screenshot_set(attributes: { screenshotDisplayType: display_type })
        iterate_over_screenshots_per_display_type(localization, app_screenshot_set, screenshots, &block)
      end
    end

    def iterate_over_screenshots_per_display_type(localization, app_screenshot_set, screenshots, &block)
      screenshots.each.with_index do |screenshot, index|
        yield(localization, app_screenshot_set, screenshot, index)
      end
    end
  end
end
