require_relative 'module'
require 'spaceship'
require 'bigdecimal'
require 'date'

module Deliver
  # Set pricing independently of App Store country availability.
  class UploadPriceTier
    def upload(options)
      validate_options!(options)
      return unless options[:price_tier] || options[:price] || options[:price_point_id]

      app = Deliver.cache[:app]
      schedule = app.fetch_app_price_schedule
      prices = schedule ? schedule.get_manual_prices : []
      territory_id = base_territory_id(options, schedule, prices)
      point = price_point(app, options, territory_id)
      base_prices = prices.select { |price| price.territory.id == territory_id }
      current = current_price(base_prices)
      if current && current.app_price_point.id == point.id
        UI.success("App price unchanged (price point #{point.id})")
        return
      end

      if current&.end_date
        UI.user_error!("The base territory has a scheduled price change. Manage this schedule in App Store Connect")
      end

      Spaceship::ConnectAPI::AppPriceSchedule.create(
        app_id: app.id,
        base_territory_id: territory_id,
        price_point_id: point.id,
        preserved_price_ids: prices.reject { |price| price == current }.map(&:id)
      )
      UI.success("Successfully updated the app price schedule")
    end

    def validate_options!(options)
      selectors = [:price_tier, :price, :price_point_id].reject { |key| options[key].nil? }
      UI.user_error!("#{selectors.join(' and ')} cannot be used together") if selectors.size > 1
      if selectors.empty? && options[:price_base_territory]
        UI.user_error!("price_base_territory requires price_tier: 0, price, or price_point_id")
      end
    end

    private

    def base_territory_id(options, schedule, prices)
      if prices.any? { |price| price.id.to_s.empty? || price.territory&.id.to_s.empty? || price.app_price_point&.id.to_s.empty? }
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
      if options[:price_point_id]
        point = points.find { |candidate| candidate.id == options[:price_point_id] }
        return point if point
      else
        amount = BigDecimal(options[:price] || "0")
        matches = points.select { |candidate| candidate.customer_price && BigDecimal(candidate.customer_price) == amount }
        UI.user_error!("Multiple price points match #{amount.to_s('F')} in #{territory_id}. Select one with price_point_id") if matches.size > 1
        return matches.first unless matches.empty?
      end
      UI.user_error!("No matching price point for #{options[:price_point_id] || options[:price] || '0'} exists for this app in #{territory_id}")
    end

    def current_price(base_prices)
      return if base_prices.empty?

      # Apple applies changes at storefront-local times. Only replace a price
      # when it is active regardless of the runner's timezone.
      now = Time.now
      earliest = now.getlocal("-12:00").to_date.iso8601
      latest = now.getlocal("+14:00").to_date.iso8601
      remaining = base_prices.reject { |price| price.end_date && price.end_date < earliest }
      current, future = remaining.partition { |price| price.start_date.nil? || price.start_date < earliest }
      if current.size != 1 || (current.first.end_date && current.first.end_date <= latest) ||
         future.any? { |price| price.start_date <= latest || current.first.end_date.nil? || price.start_date < current.first.end_date }
        UI.user_error!("Cannot safely identify the current base territory price. Check the schedule in App Store Connect")
      end
      return current.first
    end
  end
end
