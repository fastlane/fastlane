require 'spaceship/tunes/language_item'
require 'spaceship/tunes/iap_list'
require 'fastlane/markdown_table_formatter'

require_relative 'module'
require_relative 'item_to_check'
require_relative 'rule'

module Precheck
  # encapsulated the results of the rule processing, needed to return not just an array of the results of our
  # checks, but also an array of items we didn't check, just in-case we were expecting to check everything
  class RuleProcessResult
    attr_accessor :error_results # { rule: [result, result, ...] }
    attr_accessor :warning_results # { rule: [result, result, ...] }
    attr_accessor :skipped_rules
    attr_accessor :items_not_checked

    def initialize(error_results: nil,
                   warning_results: nil,
                   skipped_rules: nil,
                   items_not_checked: nil)
      @error_results = error_results
      @warning_results = warning_results
      @skipped_rules = skipped_rules
      @items_not_checked = items_not_checked
    end

    def should_trigger_user_error?
      return true if error_results.length > 0
      return false
    end

    def has_errors_or_warnings?
      return true if error_results.length > 0 || warning_results.length > 0
      return false
    end

    def items_not_checked?
      return true if items_not_checked.length > 0
      return false
    end
  end

  class RuleProcessor
    def self.process_app_and_version(app: nil, app_version: nil, rules: nil)
      items_to_check = []
      items_to_check += generate_app_items_to_check(app: app)
      items_to_check += generate_version_items_to_check(app_version: app_version)

      return process_rules(items_to_check: items_to_check, rules: rules)
    end

    def self.process_rules(items_to_check: nil, rules: nil)
      items_not_checked = items_to_check.to_set # items we haven't checked by at least one rule
      error_results = {} # rule to fields map
      warning_results = {} # rule to fields map
      skipped_rules = []

      rules.each do |rule|
        rule_config = Precheck.config[rule.key]
        rule_level = rule_config[:level].to_sym unless rule_config.nil?
        rule_level ||= Precheck.config[:default_rule_level].to_sym

        if rule_level == RULE_LEVELS[:skip]
          skipped_rules << rule
          UI.message("Skipped: #{rule.class.friendly_name}-> #{rule.description}".yellow)
          next
        end

        if rule.needs_customization?
          if rule_config.nil? || rule_config[:data].nil?
            UI.verbose("#{rule.key} excluded because no data was passed to it e.g.: #{rule.key}(data: <data here>)")
            next
          end

          custom_data = rule_config[:data]
          rule.customize_with_data(data: custom_data)
        end

        # if the rule failed at least once, we won't print a success message
        rule_failed_at_least_once = false

        items_to_check.each do |item|
          result = rule.check_item(item)

          # each rule will determine if it can handle this item, if not, it will just pass nil back
          next if result.nil?

          # we've checked this item, remove it from list of items not checked
          items_not_checked.delete(item)

          # if we passed, then go to the next item, otherwise, recode the failure
          next unless result.status == VALIDATION_STATES[:failed]
          error_results = add_new_result_to_rule_hash(rule_hash: error_results, result: result) if rule_level == RULE_LEVELS[:error]
          warning_results = add_new_result_to_rule_hash(rule_hash: warning_results, result: result) if rule_level == RULE_LEVELS[:warn]
          rule_failed_at_least_once = true
        end

        if rule_failed_at_least_once
          message = "😵  Failed: #{rule.class.friendly_name}-> #{rule.description}"
          if rule_level == RULE_LEVELS[:error]
            UI.error(message)
          else
            UI.important(message)
          end
        else
          UI.message("✅  Passed: #{rule.class.friendly_name}")
        end
      end

      return RuleProcessResult.new(
        error_results: error_results,
        warning_results: warning_results,
        skipped_rules: skipped_rules,
        items_not_checked: items_not_checked.to_a
      )
    end

    # hash will be { rule: [result, result, result] }
    def self.add_new_result_to_rule_hash(rule_hash: nil, result: nil)
      unless rule_hash.include?(result.rule)
        rule_hash[result.rule] = []
      end
      rule_results = rule_hash[result.rule]
      rule_results << result
      return rule_hash
    end

    def self.generate_app_items_to_check(app: nil)
      items = []

      # App info localizations
      app_info = Precheck.config[:use_live] ? app.fetch_live_app_info : app.fetch_latest_app_info
      app_info_localizations = app_info.get_app_info_localizations
      app_info_localizations.each do |localization|
        items << collect_text_items_from_language_item(locale: localization.locale,
                                                        value: localization.name,
                                                    item_name: :app_name,
                                        friendly_name_postfix: "app name")

        items << collect_text_items_from_language_item(locale: localization.locale,
                                                        value: localization.subtitle,
                                                    item_name: :app_subtitle,
                                        friendly_name_postfix: "app name subtitle",
                                                  is_optional: true)

        items << collect_text_items_from_language_item(locale: localization.locale,
                                                        value: localization.privacy_policy_text,
                                                    item_name: :privacy_policy_text,
                                        friendly_name_postfix: " tv privacy policy")

        items << collect_urls_from_language_item(locale: localization.locale,
                                                        value: localization.privacy_policy_url,
                                                    item_name: :privacy_policy_url,
                                        friendly_name_postfix: "privacy URL",
                                                  is_optional: true)
      end

      should_include_iap = Precheck.config[:include_in_app_purchases]
      if should_include_iap
        UI.message("Reading in-app purchases. If you have a lot, this might take a while")
        UI.message("You can disable IAP checking by setting the `include_in_app_purchases` flag to `false`")
        in_app_purchases = get_iaps(app_id: app.id)
        in_app_purchases ||= []
        in_app_purchases.each do |purchase|
          items += collect_iap_language_items(purchase_edit_versions: purchase.edit.versions)
        end
        UI.message("Done reading in-app purchases")
      end

      return items
    end

    def self.generate_version_items_to_check(app_version: nil)
      items = []

      items << TextItemToCheck.new(app_version.copyright, :copyright, "copyright")

      # Version localizations
      version_localizations = app_version.get_app_store_version_localizations
      version_localizations.each do |localization|
        items << collect_text_items_from_language_item(locale: localization.locale,
                                                        value: localization.keywords,
                                                    item_name: :keywords,
                                        friendly_name_postfix: "keywords")

        items << collect_text_items_from_language_item(locale: localization.locale,
                                                        value: localization.description,
                                                    item_name: :description,
                                        friendly_name_postfix: "description")

        items << collect_text_items_from_language_item(locale: localization.locale,
                                                        value: localization.whats_new,
                                                    item_name: :release_notes,
                                        friendly_name_postfix: "what's new")

        items << collect_urls_from_language_item(locale: localization.locale,
                                                        value: localization.support_url,
                                                    item_name: :support_url,
                                        friendly_name_postfix: "support URL")

        items << collect_urls_from_language_item(locale: localization.locale,
                                                        value: localization.marketing_url,
                                                    item_name: :marketing_url,
                                        friendly_name_postfix: "marketing URL",
                                                 is_optional: true)
      end

      return items
    end

    # As of 2020-09-04, this is the only non App Store Connect call in prechecks
    # This will need to get replaced when the API becomes available
    def self.get_iaps(app_id: nil, include_deleted: false)
      r = Spaceship::Tunes.client.iaps(app_id: app_id)
      return_iaps = []
      r.each do |product|
        attrs = product

        # This is not great but Spaceship::Tunes::IAPList.factory looks
        # for `application.apple_id`
        mock_application = OpenStruct.new({ apple_id: app_id })
        attrs[:application] = mock_application

        loaded_iap = Spaceship::Tunes::IAPList.factory(attrs)
        next if loaded_iap.status == "deleted" && !include_deleted
        return_iaps << loaded_iap
      end
      return return_iaps
    end

    def self.collect_iap_language_items(purchase_edit_versions: nil, is_optional: false)
      items = []
      purchase_edit_versions.each do |language_key, hash|
        name = hash[:name]
        description = hash[:description]
        items << TextItemToCheck.new(name, :in_app_purchase, "in-app purchase name: #{name}: (#{language_key})", is_optional)
        items << TextItemToCheck.new(description, :in_app_purchase, "in-app purchase desc: #{description}: (#{language_key})", is_optional)
      end
      return items
    end

    # a few attributes are LanguageItem this method creates a TextItemToCheck for each pair
    def self.collect_text_items_from_language_item(locale: nil, value: nil, item_name: nil, friendly_name_postfix: nil, is_optional: false)
      return TextItemToCheck.new(value, item_name, "#{friendly_name_postfix}: (#{locale})", is_optional)
    end

    def self.collect_urls_from_language_item(locale: nil, value: nil, item_name: nil, friendly_name_postfix: nil, is_optional: false)
      return URLItemToCheck.new(value, item_name, "#{friendly_name_postfix}: (#{locale})", is_optional)
    end
  end
end

# we want to get some of the same behavior hashes has, so use this mixin specifically designed for Spaceship::Tunes::LanguageItem
# because we use .each
module LanguageItemHashBehavior
  # this is used to create a hash-like .each method.
  def each(&block)
    keys.each { |key| yield(key, get_value(key: key)) }
  end
end

class Spaceship::Tunes::LanguageItem
  include LanguageItemHashBehavior
end
