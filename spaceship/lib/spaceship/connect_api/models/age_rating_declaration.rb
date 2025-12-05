require_relative '../model'
module Spaceship
  class ConnectAPI
    class AgeRatingDeclaration
      include Spaceship::ConnectAPI::Model

      # Rating
      attr_accessor :alcohol_tobacco_or_drug_use_or_references
      attr_accessor :contests
      attr_accessor :gambling_simulated
      attr_accessor :guns_or_other_weapons
      attr_accessor :horror_or_fear_themes
      attr_accessor :mature_or_suggestive_themes
      attr_accessor :medical_or_treatment_information
      attr_accessor :profanity_or_crude_humor
      attr_accessor :sexual_content_graphic_and_nudity
      attr_accessor :sexual_content_or_nudity
      attr_accessor :violence_cartoon_or_fantasy
      attr_accessor :violence_realistic_prolonged_graphic_or_sadistic
      attr_accessor :violence_realistic

      # Boolean
      attr_accessor :advertising
      attr_accessor :age_assurance
      attr_accessor :gambling
      attr_accessor :health_or_wellness_topics
      attr_accessor :loot_box
      attr_accessor :messaging_and_chat
      attr_accessor :parental_controls
      attr_accessor :unrestricted_web_access
      attr_accessor :user_generated_content

      # AgeRating
      attr_accessor :age_rating_override_v2

      # KoreaAgeRating
      attr_accessor :korea_age_rating_override

      # KidsAge
      attr_accessor :kids_age_band

      # URL
      attr_accessor :developer_age_rating_info_url

      # Deprecated as of App Store Connect API 1.3
      attr_accessor :gambling_and_contests

      module Rating
        NONE = "NONE"
        INFREQUENT = "INFREQUENT"
        INFREQUENT_OR_MILD = "INFREQUENT_OR_MILD"
        FREQUENT = "FREQUENT"
        FREQUENT_OR_INTENSE = "FREQUENT_OR_INTENSE"
      end

      module AgeRating
        NONE = "NONE"
        NINE_PLUS = "NINE_PLUS"
        THIRTEEN_PLUS = "THIRTEEN_PLUS"
        SIXTEEN_PLUS = "SIXTEEN_PLUS"
        EIGHTEEN_PLUS = "EIGHTEEN_PLUS"
        UNRATED = "UNRATED"
      end

      module KoreaAgeRating
        NONE = "NONE"
        FIFTEEN_PLUS = "FIFTEEN_PLUS"
        NINETEEN_PLUS = "NINETEEN_PLUS"
      end

      module KidsAge
        FIVE_AND_UNDER = "FIVE_AND_UNDER"
        SIX_TO_EIGHT = "SIX_TO_EIGHT"
        NINE_TO_ELEVEN = "NINE_TO_ELEVEN"
      end

      attr_mapping({
        "advertising" => "advertising",
        "ageAssurance" => "age_assurance",
        "ageRatingOverrideV2" => "age_rating_override_v2",
        "alcoholTobaccoOrDrugUseOrReferences" => "alcohol_tobacco_or_drug_use_or_references",
        "contests" => "contests",
        "developerAgeRatingInfoUrl" => "developer_age_rating_info_url",
        "gambling" => "gambling",
        "gamblingSimulated" => "gambling_simulated",
        "gunsOrOtherWeapons" => "guns_or_other_weapons",
        "healthOrWellnessTopics" => "health_or_wellness_topics",
        "horrorOrFearThemes" => "horror_or_fear_themes",
        "kidsAgeBand" => "kids_age_band",
        "koreaAgeRatingOverride" => "korea_age_rating_override",
        "lootBox" => "loot_box",
        "matureOrSuggestiveThemes" => "mature_or_suggestive_themes",
        "medicalOrTreatmentInformation" => "medical_or_treatment_information",
        "messagingAndChat" => "messaging_and_chat",
        "parentalControls" => "parental_controls",
        "profanityOrCrudeHumor" => "profanity_or_crude_humor",
        "sexualContentGraphicAndNudity" => "sexual_content_graphic_and_nudity",
        "sexualContentOrNudity" => "sexual_content_or_nudity",
        "unrestrictedWebAccess" => "unrestricted_web_access",
        "userGeneratedContent" => "user_generated_content",
        "violenceCartoonOrFantasy" => "violence_cartoon_or_fantasy",
        "violenceRealisticProlongedGraphicOrSadistic" => "violence_realistic_prolonged_graphic_or_sadistic",
        "violenceRealistic" => "violence_realistic",

        # Deprecated as of App Store Connect API 1.3 - No longer accepted by API
        "gamblingAndContests" => "gambling_and_contests",
      })

      def self.type
        return "ageRatingDeclarations"
      end

      LEGACY_AGE_RATING_ITC_MAP = {
        "CARTOON_FANTASY_VIOLENCE" => "violenceCartoonOrFantasy",
        "REALISTIC_VIOLENCE" => "violenceRealistic",
        "PROLONGED_GRAPHIC_SADISTIC_REALISTIC_VIOLENCE" => "violenceRealisticProlongedGraphicOrSadistic",
        "PROFANITY_CRUDE_HUMOR" => "profanityOrCrudeHumor",
        "MATURE_SUGGESTIVE" => "matureOrSuggestiveThemes",
        "HORROR" => "horrorOrFearThemes",
        "MEDICAL_TREATMENT_INFO" => "medicalOrTreatmentInformation",
        "ALCOHOL_TOBACCO_DRUGS" => "alcoholTobaccoOrDrugUseOrReferences",
        "GAMBLING" => "gamblingSimulated",
        "SEXUAL_CONTENT_NUDITY" => "sexualContentOrNudity",
        "GRAPHIC_SEXUAL_CONTENT_NUDITY" => "sexualContentGraphicAndNudity",
        "UNRESTRICTED_WEB_ACCESS" => "unrestrictedWebAccess",
        "GAMBLING_CONTESTS" => "gamblingAndContests"
      }

      LEGACY_RATING_VALUE_ITC_MAP = {
        0 => Rating::NONE,
        1 => Rating::INFREQUENT_OR_MILD,
        2 => Rating::FREQUENT_OR_INTENSE
      }

      LEGACY_BOOLEAN_VALUE_ITC_MAP = {
        0 => false,
        1 => true
      }

      def self.map_deprecation_if_possible(attributes)
        attributes = attributes.dup
        messages = []
        errors = []

        value = attributes.delete('gamblingAndContests')
        return attributes, messages, errors if value.nil?

        messages << "Age Rating 'gamblingAndContests' has been deprecated and split into 'gambling' and 'contests'"

        attributes['gambling'] = value
        if value == true
          errors << "'gamblingAndContests' could not be mapped to 'contests' - 'contests' requires a value of 'NONE', 'INFREQUENT_OR_MILD', or 'FREQUENT_OR_INTENSE'"
          attributes['contests'] = value
        else
          attributes['contests'] = 'NONE'
        end

        return attributes, messages, errors
      end

      def self.map_key_from_itc(key)
        key = key.gsub("MZGenre.", "")
        return nil if key.empty?
        LEGACY_AGE_RATING_ITC_MAP[key] || key
      end

      def self.map_value_from_itc(key, value)
        boolean_keys = [
          "advertising",
          "ageAssurance",
          "gambling",
          "gamblingAndContests",
          "healthOrWellnessTopics",
          "lootBox",
          "messagingAndChat",
          "parentalControls",
          "unrestrictedWebAccess",
          "userGeneratedContent"
        ]

        if boolean_keys.include?(key)
          new_value = LEGACY_BOOLEAN_VALUE_ITC_MAP[value]
          return value if new_value.nil?
          return new_value
        else
          return LEGACY_RATING_VALUE_ITC_MAP[value] || value
        end

        return value
      end

      #
      # API
      #

      def update(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        attributes = reverse_attr_mapping(attributes)
        client.patch_age_rating_declaration(age_rating_declaration_id: id, attributes: attributes)
      end
    end
  end
end
