require 'spaceship'
require 'fastlane/markdown_table_formatter'
require 'review/item_to_check'

module Review
  class RuleProcessor
    def self.process_app_version(app_version: nil, rules: nil)
      items_to_check = []
      items_to_check += generate_text_items_to_check(app_version: app_version)
      items_to_check += generate_url_items_to_check(app_version: app_version)

      return process_rules(items_to_check: items_to_check, rules: rules)
    end

    def self.process_rules(items_to_check: nil, rules: nil)
      results = [] # array of RuleCheckResult
      rules.each do |rule|
        items_to_check.each do |item|
          result = rule.check_item(item)
          unless result.nil?
            results << result
          end
        end
      end

      return results
    end

    def self.generate_url_items_to_check(app_version: nil)
      items = []
      items += collect_urls_from_hash(hash: app_version.support_url,
                                 item_name: :support_url,
                     friendly_name_postfix: "support URL")
      items += collect_urls_from_hash(hash: app_version.marketing_url,
                                 item_name: :marketing_url,
                     friendly_name_postfix: "marketing URL")
      return items
    end

    def self.collect_urls_from_hash(hash: nil, item_name: nil, friendly_name_postfix: nil)
      items = []
      hash.each do |key, value|
        items << URLItemToCheck.new(value, item_name, "#{friendly_name_postfix}: (#{key})")
      end
      return items
    end

    def self.generate_text_items_to_check(app_version: nil)
      items = []
      items << TextItemToCheck.new(app_version.copyright, :copyright, "copyright")
      items << TextItemToCheck.new(app_version.review_first_name, :review_first_name, "review first name")
      items << TextItemToCheck.new(app_version.review_last_name, :review_last_name, "review last name")
      items << TextItemToCheck.new(app_version.review_phone_number, :review_phone_number, "review phone number")
      items << TextItemToCheck.new(app_version.review_email, :review_email, "review email")
      items << TextItemToCheck.new(app_version.review_demo_user, :review_demo_user, "review demo user")
      items << TextItemToCheck.new(app_version.review_notes, :review_notes, "review notes")

      items += collect_text_items_from_hash(hash: app_version.keywords,
                                       item_name: :keywords,
                           friendly_name_postfix: "keywords")

      items += collect_text_items_from_hash(hash: app_version.description,
                                       item_name: :description,
                           friendly_name_postfix: "description")

      items += collect_text_items_from_hash(hash: app_version.release_notes,
                                       item_name: :release_notes,
                           friendly_name_postfix: "release notes")
      return items
    end

    def self.collect_text_items_from_hash(hash: nil, item_name: nil, friendly_name_postfix: nil)
      items = []
      hash.each do |key, value|
        items << TextItemToCheck.new(value, item_name, "#{friendly_name_postfix}: (#{key})")
      end
      return items
    end
  end
end

# We want to get some of the same behavior hashes has, so use this mixin specifically designed for Spaceship::Tunes::LanguageItem
module LanguageItemHashBehavior
  # this is used to create a hash-like .each method.
  def each(&block)
    keys.each { |key| yield(key, get_value(key: key)) }
  end
end

class Spaceship::Tunes::LanguageItem
  include LanguageItemHashBehavior
end
