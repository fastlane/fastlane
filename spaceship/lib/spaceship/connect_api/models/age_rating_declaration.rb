require_relative '../model'
module Spaceship
  class ConnectAPI
    class AgeRatingDeclaration
      include Spaceship::ConnectAPI::Model

      # Rating
      attr_accessor :alcohol_tobacco_or_drug_use_or_references
      attr_accessor :gambling_simulated
      attr_accessor :medical_or_treatment_information
      attr_accessor :profanity_or_crude_humor
      attr_accessor :sexual_content_graphic_and_nudity
      attr_accessor :horror_or_fear_themes
      attr_accessor :mature_or_suggestive_themes
      attr_accessor :violence_cartoon_or_fantasy
      attr_accessor :violence_realistic_prolonged_graphic_or_sadistic
      attr_accessor :violence_realistic

      # boolean
      attr_accessor :gambling_and_contests
      attr_accessor :unrestricted_web_access

      # KidsAge
      attr_accessor :kids_age_band

      module Rating
        NONE = "NONE"
        INFREQUENT_OR_MILD = "INFREQUENT_OR_MILD"
        FREQUENT_OR_INTENSE = "FREQUENT_OR_INTENSE"
      end

      module KidsAge
        FIVE_AND_UNDER = "FIVE_AND_UNDER"
        SIX_TO_EIGHT = "SIX_TO_EIGHT"
        NINE_TO_ELEVEN = "NINE_TO_ELEVEN"
      end

      attr_mapping({
        "alcoholTobaccoOrDrugUseOrReferences" => "alcohol_tobacco_or_drug_use_or_references",
        "gamblingAndContests" => "gambling_and_contests",
        "gamblingSimulated" => "gambling_simulated",
        "medicalOrTreatmentInformation" => "medical_or_treatment_information",
        "profanityOrCrudeHumor" => "profanity_or_crude_humor",
        "sexualContentGraphicAndNudity" => "sexual_content_graphic_and_nudity",
        "sexualContentOrNudity" => "sexual_content_or_nudity",
        "horrorOrFearThemes" => "horror_or_fear_themes",
        "matureOrSuggestiveThemes" => "mature_or_suggestive_themes",
        "unrestrictedWebAccess" => "unrestricted_web_access",
        "violenceCartoonOrFantasy" => "violence_cartoon_or_fantasy",
        "violenceRealisticProlongedGraphicOrSadistic" => "violence_realistic_prolonged_graphic_or_sadistic",
        "violenceRealistic" => "violence_realistic",
        "kidsAgeBand" => "kids_age_band"
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

      def self.map_key_from_itc(key)
        key = key.gsub("MZGenre.", "")
        return nil if key.empty?
        LEGACY_AGE_RATING_ITC_MAP[key] || key
      end

      def self.map_value_from_itc(key, value)
        if ["gamblingAndContests", "unrestrictedWebAccess"].include?(key)
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
