module Fastlane::ActionSets::Amazon
  # Describes a localized presence of an app `Edit` in the Amazon Appstore.
  class Listing
    # @return [String] The language code of the listing (like en-US)
    attr_accessor :language
    # @return [String] The localized title of the listing
    attr_accessor :title
    # @return [String] The localized long description text for the listing
    attr_accessor :full_description
    # @return [String] The localized brief description text for the listing
    attr_accessor :short_description
    # @return [String] The localized release notes for the listing
    attr_accessor :recent_changes
    # @return [Array<String>] Localized functionality highlights for the listing
    attr_accessor :feature_bullets
    # @return [Array<String>] Any localized keywords for the listing
    attr_accessor :keywords

    # @param [Hash] json
    def initialize(json)
      @language = json['language']
      @title = json['title']
      @full_description = json['fullDescription']
      @short_description = json['shortDescription']
      @recent_changes = json['recentChanges']
      @feature_bullets = json['featureBullets']
      @keywords = json['keywords']
    end

    # @return [Hash]
    def to_json
      {
        'language' => language,
        'title' => title,
        'fullDescription' => full_description,
        'shortDescription' => short_description,
        'recentChanges' => recent_changes,
        'featureBullets' => feature_bullets,
        'keywords' => keywords,
      }
    end

    # @param [Listing] other
    # @return [Boolean]
    def ==(other)
      language == other.language &&
        title == other.title &&
        full_description == other.full_description &&
        short_description == other.short_description &&
        recent_changes == other.recent_changes &&
        feature_bullets == other.feature_bullets &&
        keywords == other.keywords
    end

    def to_s
      "<Fastlane::ActionSets::Amazon::Listing:#{object_id} language=>\"#{language}\" title=>\"#{title}\">"
    end
  end
end
