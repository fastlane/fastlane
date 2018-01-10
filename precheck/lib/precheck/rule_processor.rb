require 'spaceship/tunes/language_item'
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
      items_to_check += generate_text_items_to_check(app: app, app_version: app_version)
      items_to_check += generate_url_items_to_check(app: app, app_version: app_version)

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

    def self.generate_url_items_to_check(app: nil, app_version: nil)
      items = []
      items += collect_urls_from_hash(hash: app_version.support_url,
                                 item_name: :support_url,
                     friendly_name_postfix: "support URL")
      items += collect_urls_from_hash(hash: app_version.marketing_url,
                                 item_name: :marketing_url,
                     friendly_name_postfix: "marketing URL",
                               is_optional: true)

      items += collect_urls_from_hash(hash: app.details.privacy_url,
                                 item_name: :privacy_url,
                     friendly_name_postfix: "privacy URL",
                               is_optional: true)
      return items
    end

    def self.collect_urls_from_hash(hash: nil, item_name: nil, friendly_name_postfix: nil, is_optional: false)
      items = []
      hash.each do |key, value|
        items << URLItemToCheck.new(value, item_name, "#{friendly_name_postfix}: (#{key})", is_optional)
      end
      return items
    end

    def self.generate_text_items_to_check(app: nil, app_version: nil)
      items = []

      items << TextItemToCheck.new(app_version.copyright, :copyright, "copyright")

      items += collect_text_items_from_language_item(hash: app_version.keywords,
                                                item_name: :keywords,
                                    friendly_name_postfix: "keywords")

      items += collect_text_items_from_language_item(hash: app_version.description,
                                                item_name: :description,
                                    friendly_name_postfix: "description")

      items += collect_text_items_from_language_item(hash: app_version.release_notes,
                                                item_name: :release_notes,
                                    friendly_name_postfix: "release notes")

      items += collect_text_items_from_language_item(hash: app.details.name,
                                                item_name: :app_name,
                                    friendly_name_postfix: "app name")

      items += collect_text_items_from_language_item(hash: app.details.apple_tv_privacy_policy,
                                                item_name: :app_subtitle,
                                    friendly_name_postfix: " tv privacy policy")

      items += collect_text_items_from_language_item(hash: app.details.subtitle,
                                                item_name: :app_subtitle,
                                    friendly_name_postfix: "app name subtitle",
                                              is_optional: true)

      should_include_iap = Precheck.config[:include_in_app_purchases]
      if should_include_iap
        UI.message("Reading in-app purchases. If you have a lot, this might take a while")
        UI.message("You can disable IAP checking by setting the `include_in_app_purchases` flag to `false`")
        in_app_purchases = app.in_app_purchases.all
        in_app_purchases ||= []
        in_app_purchases.each do |purchase|
          items += collect_iap_language_items(purchase_edit_versions: purchase.edit.versions)
        end
        UI.message("Done reading in-app purchases")
      end

      return items
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
    def self.collect_text_items_from_language_item(hash: nil, item_name: nil, friendly_name_postfix: nil, is_optional: false)
      items = []
      hash.each do |key, value|
        items << TextItemToCheck.new(value, item_name, "#{friendly_name_postfix}: (#{key})", is_optional)
      end
      return items
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
