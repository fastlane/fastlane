require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppCategory
      include Spaceship::ConnectAPI::Model

      attr_accessor :platforms

      attr_mapping({
        "platforms" => "platforms"
      })

      def self.type
        return "appCategories"
      end

      LEGACY_CATEGORY_ITC_MAP = {
        "Apps.Food_Drink" => "FOOD_AND_DRINK",
        "Business" => "BUSINESS",
        "Education" => "EDUCATION",
        "SocialNetworking" => "SOCIAL_NETWORKING",
        "Book" => "BOOKS",
        "Sports" => "SPORTS",
        "Finance" => "FINANCE",
        "Reference" => "REFERENCE",
        "Apps.GraphicsDesign" => "GRAPHICS_AND_DESIGN",
        "Apps.DeveloperTools" => "DEVELOPER_TOOLS",
        "Healthcare_Fitness" => "HEALTH_AND_FITNESS",
        "Music" => "MUSIC",
        "Weather" => "WEATHER",
        "Travel" => "TRAVEL",
        "Entertainment" => "ENTERTAINMENT",
        "Stickers" => "STICKERS",
        "Games" => "GAMES",
        "Lifestyle" => "LIFESTYLE",
        "Medical" => "MEDICAL",
        "Apps.Newsstand" => "MAGAZINES_AND_NEWSPAPERS",
        "Utilities" => "UTILITIES",
        "Apps.Shopping" => "SHOPPING",
        "Productivity" => "PRODUCTIVITY",
        "News" => "NEWS",
        "Photography" => "PHOTO_AND_VIDEO",
        "Navigation" => "NAVIGATION"
      }

      LEGACY_SUBCATEGORY_ITC_MAP = {
        "Apps.Stickers.Places" => "STICKERS_PLACES_AND_OBJECTS",
        "Apps.Stickers.Emotions" => "STICKERS_EMOJI_AND_EXPRESSIONS",
        "Apps.Stickers.BirthdaysAndCelebrations" => "STICKERS_CELEBRATIONS",
        "Apps.Stickers.Celebrities" => "STICKERS_CELEBRITIES",
        "Apps.Stickers.MoviesAndTV" => "STICKERS_MOVIES_AND_TV",
        "Apps.Stickers.Sports" => "STICKERS_SPORTS_AND_ACTIVITIES",
        "Apps.Stickers.FoodAndDrink" => "STICKERS_EATING_AND_DRINKING",
        "Apps.Stickers.Characters" => "STICKERS_CHARACTERS",
        "Apps.Stickers.Animals" => "STICKERS_ANIMALS",
        "Apps.Stickers.Fashion" => "STICKERS_FASHION",
        "Apps.Stickers.Art" => "STICKERS_ART",
        "Apps.Stickers.Games" => "STICKERS_GAMING",
        "Apps.Stickers.KidsAndFamily" => "STICKERS_KIDS_AND_FAMILY",
        "Apps.Stickers.People" => "STICKERS_PEOPLE",
        "Apps.Stickers.Music" => "STICKERS_MUSIC",

        "Sports" => "GAMES_SPORTS",
        "Word" => "GAMES_WORD",
        "Music" => "GAMES_MUSIC",
        "Adventure" => "GAMES_ADVENTURE",
        "Action" => "GAMES_ACTION",
        "RolePlaying" => "GAMES_ROLE_PLAYING",
        "Arcade" => "GAMES_CASUAL",
        "Board" => "GAMES_BOARD",
        "Trivia" => "GAMES_TRIVIA",
        "Card" => "GAMES_CARD",
        "Puzzle" => "GAMES_PUZZLE",
        "Casino" => "GAMES_CASINO",
        "Strategy" => "GAMES_STRATEGY",
        "Simulation" => "GAMES_SIMULATION",
        "Racing" => "GAMES_RACING",
        "Family" => "GAMES_FAMILY"
      }

      def self.map_category_from_itc(category)
        category = category.gsub("MZGenre.", "")
        return nil if category.empty?
        LEGACY_CATEGORY_ITC_MAP[category] || category
      end

      def self.map_subcategory_from_itc(category)
        category = category.gsub("MZGenre.", "")
        return nil if category.empty?
        LEGACY_SUBCATEGORY_ITC_MAP[category] || category
      end
    end
  end
end
