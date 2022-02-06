module Fastlane::ActionSets::Amazon
  # Describes additional metadata that goes along with an `Edit`.
  class Details
    # @return [String] The default language code for the Edit
    attr_accessor :default_language
    # @return [String] The fully-qualified web address where support can be reached
    attr_accessor :contact_website
    # @return [String] The email address where an app support contact person can be reached
    attr_accessor :contact_email
    # @return [String] The phone number where an app support contact person can be reached
    attr_accessor :contact_phone

    # @param [Hash] json
    def initialize(json)
      @default_language = json['defaultLanguage']
      @contact_website = json['contactWebsite']
      @contact_email = json['contactEmail']
      @contact_phone = json['contactPhone']
    end

    # @return [Hash]
    def to_json
      {
        'defaultLanguage' => @default_language,
        'contactWebsite' => @contact_website,
        'contactEmail' => @contact_email,
        'contactPhone' => @contact_phone,
      }
    end

    # @param [Details] other
    # @return [Boolean]
    def ==(other)
      default_language == other.default_language &&
        contact_website == other.contact_website &&
        contact_email == other.contact_email &&
        contact_phone == other.contact_phone
    end

    def to_s
      "<Fastlane::ActionSets::Amazon::Details:#{object_id} default_language=>\"#{default_language}\" contact_email=>\"#{contact_email}\">"
    end
  end
end
