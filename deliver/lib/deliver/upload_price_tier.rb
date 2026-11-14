require_relative 'module'
require 'spaceship'
require 'bigdecimal'
require 'date'

module Deliver
  # Set pricing independently of App Store country availability.
  class UploadPriceTier
    def upload(options)
      validate_options!(options)
      return if options[:price_tier].nil? && options[:price_point_id].nil?

      app = Deliver.cache[:app]
      schedule = app.fetch_app_price_schedule
      prices = schedule ? schedule.get_manual_prices : []
      territory_id = base_territory_id(options, schedule, prices)
      point = price_point(app, options, territory_id)
      today, earliest_today, latest_today = comparison_dates
      immediate = options[:price_start_date].nil?
      start_date = options[:price_start_date] || today
      end_date = options[:price_end_date]
      territory_prices = prices.select { |price| price.territory.id == territory_id }
      if immediate && territory_prices.any? { |price| [price.start_date, price.end_date].compact.any? { |date| date.between?(earliest_today, latest_today) } }
        UI.user_error!("A scheduled price boundary may be taking effect in the base territory. Set price_start_date explicitly instead of relying on the runner's timezone")
      end
      end_date ||= next_change(territory_prices, start_date)
      if territory_prices.empty? && (options[:price_start_date] || end_date)
        UI.user_error!("Initialize pricing without price_start_date or price_end_date before scheduling a change")
      end

      if unchanged?(territory_prices, point.id, start_date, end_date)
        UI.success("App price unchanged (price point #{point.id})")
        return
      end

      manual_prices = replace_interval(prices, territory_id, point.id, start_date, end_date, immediate: immediate, earliest_today: earliest_today)
      Spaceship::ConnectAPI::AppPriceSchedule.create(
        app_id: app.id,
        base_territory_id: territory_id,
        manual_prices: manual_prices
      )
      UI.success("Successfully updated the app price schedule")
    end

    def validate_options!(options)
      # ConfigItem only checks direct parameters. Pricing must not silently choose
      # Free over a paid price point resolved from the environment or Deliverfile.
      if !options[:price_tier].nil? && !options[:price_point_id].nil?
        UI.user_error!("price_tier and price_point_id cannot be used together")
      end

      if options[:price_tier].nil? && options[:price_point_id].nil?
        if [:price_base_territory, :price_start_date, :price_end_date].any? { |key| options[key] }
          UI.user_error!("Pricing dates and base territory require price_tier: 0 or price_point_id")
        end
        return
      end

      if options[:price_start_date] && options[:price_end_date] && options[:price_end_date] <= options[:price_start_date]
        UI.user_error!("price_end_date must be after price_start_date")
      end
      if options[:price_start_date].nil? && options[:price_end_date] && options[:price_end_date] <= comparison_dates.last
        UI.user_error!("price_end_date must be in the future for an immediate change. Set price_start_date explicitly when the end date may already have started in the base territory")
      end
    end

    private

    def base_territory_id(options, schedule, prices)
      if prices.any? { |price| price.territory.nil? || price.app_price_point.nil? }
        UI.user_error!("Could not read all existing price relationships; no pricing changes were made")
      end
      existing = schedule&.base_territory&.id
      if existing.nil? && !prices.empty?
        UI.user_error!("Could not read the existing base territory; no pricing changes were made")
      end
      requested = options[:price_base_territory]
      if existing && requested && existing != requested && !prices.empty?
        UI.user_error!("The app's base territory is #{existing}. Change it in App Store Connect before using #{requested}")
      end
      return requested || existing || "USA"
    end

    def price_point(app, options, territory_id)
      points = app.get_app_price_points(filter: { territory: territory_id })
      point = if options[:price_point_id]
                points.find { |candidate| candidate.id == options[:price_point_id] }
              else
                points.find { |candidate| candidate.customer_price && BigDecimal(candidate.customer_price).zero? }
              end
      UI.user_error!("No matching price point exists for this app in #{territory_id}") unless point
      return point
    end

    # Apple applies dates at territory-specific times. Avoid guessing whether a
    # boundary is active when calendars can disagree across storefronts.
    def comparison_dates
      now = Time.now
      return [now.getutc.to_date, now.getlocal("-12:00").to_date, now.getlocal("+14:00").to_date].map(&:iso8601)
    end

    def next_change(prices, start_date)
      return prices.flat_map { |price| [price.start_date, price.end_date] }.compact.select { |date| date > start_date }.min
    end

    def unchanged?(prices, point_id, start_date, end_date)
      return prices.any? do |price|
        price.app_price_point.id == point_id &&
        (price.start_date.nil? || price.start_date <= start_date) &&
        (price.end_date.nil? || (end_date && price.end_date >= end_date))
      end
    end

    # Keep unmodified prices by ID, including historical prices and other countries.
    # Split only intervals overlapping the requested change. A temporary price
    # restores the former price at its end; an open-ended change stops at the next
    # existing scheduled change instead of silently discarding that schedule.
    def replace_interval(prices, territory_id, point_id, start_date, end_date, immediate:, earliest_today:)
      result = prices.flat_map do |price|
        if price.territory.id != territory_id ||
           (price.end_date && price.end_date <= start_date) ||
           (end_date && price.start_date && price.start_date >= end_date)
          next [{ id: price.id }]
        end

        intervals = []
        if !immediate && (price.start_date.nil? || price.start_date < start_date)
          prefix_start = price.start_date
          prefix_start = nil if prefix_start && prefix_start < earliest_today
          intervals << price_interval(price.app_price_point.id, prefix_start, start_date)
        end
        if end_date && (price.end_date.nil? || price.end_date > end_date)
          intervals << price_interval(price.app_price_point.id, end_date, price.end_date)
        end
        intervals
      end
      result << price_interval(point_id, immediate ? nil : start_date, end_date)
      return result
    end

    def price_interval(point_id, start_date, end_date)
      return { app_price_point_id: point_id, start_date: start_date, end_date: end_date }
    end
  end
end
