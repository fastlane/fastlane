module Spaceship
  module Tunes
    class AppDetails < TunesBase
      attr_accessor :application

      ####
      # Localized values
      ####

      # @return (Array) Raw access the all available languages. You shouldn't use it probbaly
      attr_accessor :languages

      # @return (Hash) A hash representing the app name in all languages
      attr_reader :name

      # @return (Hash) A hash representing the keywords in all languages
      attr_reader :privacy_url

      attr_mapping(
        'localizedMetadata.value' => :languages
      )

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          obj = self.new(attrs)
          obj.unfold_languages

          return obj
        end
      end

      # Prefill name, privacy url
      def unfold_languages
        {
          name: :name,
          privacyPolicyUrl: :privacy_url
        }.each do |json, attribute|
          instance_variable_set("@#{attribute}".to_sym, LanguageItem.new(json, languages))
        end
      end

      # Push all changes that were made back to iTunes Connect
      def save!
        client.update_app_details!(application.apple_id, raw_data)
      end

      #####################################################
      # @!group General
      #####################################################
      def setup
      end
    end
  end
end
