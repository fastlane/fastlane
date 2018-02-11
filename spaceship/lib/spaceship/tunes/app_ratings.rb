require_relative 'app_review'

module Spaceship
  module Tunes
    # Represents app ratings from iTunesConnect
    class AppRatings < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      #   this version is for
      attr_accessor :application

      # @return (Integer) total number of ratings recevied
      attr_accessor :rating_count

      # @return (Integer) total number of one star ratings recevied
      attr_accessor :one_star_rating_count

      # @return (Integer) total number of two star ratings recevied
      attr_accessor :two_star_rating_count

      # @return (Integer) total number of three star ratings recevied
      attr_accessor :three_star_rating_count

      # @return (Integer) total number of four star ratings recevied
      attr_accessor :four_star_rating_count

      # @return (Integer) total number of five star ratings recevied
      attr_accessor :five_star_rating_count

      attr_mapping({
        'reviewCount' => :review_count,
        'ratingCount' => :rating_count,
        'ratingOneCount' => :one_star_rating_count,
        'ratingTwoCount' => :two_star_rating_count,
        'ratingThreeCount' => :three_star_rating_count,
        'ratingFourCount' => :four_star_rating_count,
        'ratingFiveCount' => :five_star_rating_count
      })

      # @return (Float) the average rating for this summary (rounded to 2 decimal places)
      def average_rating
        ((one_star_rating_count +
          (two_star_rating_count * 2) +
          (three_star_rating_count * 3) +
          (four_star_rating_count * 4) +
          (five_star_rating_count * 5)) / rating_count.to_f).round(2)
      end

      # @return (Array) of Review Objects
      def reviews(store_front = '', version_id = '')
        raw_reviews = client.get_reviews(application.apple_id, application.platform, store_front, version_id)
        raw_reviews.map do |review|
          review["value"]["application"] = self.application
          AppReview.factory(review["value"])
        end
      end
    end
  end
end
