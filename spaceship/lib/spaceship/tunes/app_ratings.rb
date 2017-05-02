module Spaceship
  module Tunes
    # Represents app ratings from iTunesConnect
    class AppRatings < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      #   this version is for
      attr_accessor :application

      # @return (Spaceship::Tunes::AppRatingSummary) A summary of the overall ratings for the application
      attr_accessor :rating_summary

      # @return (Hash) mapping country codes to a (Spaceship::Tunes::AppRatingSummary) summary of ratings for that country
      attr_reader :store_fronts

      # @return (Hash) of iTunesConnect version id's to readable version numbers
      attr_reader :versions

      attr_mapping({
        'versions' => :versions
      })

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          obj = self.new(attrs)

          obj.unfold_rating_summary(attrs['ratings'])
          obj.unfold_store_fronts(attrs['storeFronts'])

          return obj
        end
      end

      def unfold_rating_summary(attrs)
        unfolded_rating_summary = AppRatingSummary.new(attrs)
        instance_variable_set(:@rating_summary, unfolded_rating_summary)
      end

      def unfold_store_fronts(attrs)
        unfolded_store_fronts = {}

        attrs.each do |info|
          unfolded_store_fronts[info['countryCode']] = AppRatingSummary.new(info['ratings'])
        end

        instance_variable_set(:@store_fronts, unfolded_store_fronts)
      end

      # @return (Array) of Review Objects
      def reviews(store_front, versionId = '')
        raw_reviews = client.get_reviews(application.apple_id, application.platform, store_front, versionId)
        raw_reviews.map do |review|
          review["value"]["application"] = self.application
          AppReview.factory(review["value"])
        end
      end
    end

    class DeveloperResponse < TunesBase
      attr_reader :id
      attr_reader :response
      attr_reader :last_modified
      attr_reader :hidden
      attr_reader :state
      attr_accessor :application
      attr_accessor :review_id

      attr_mapping({
        'responseId' => :id,
        'response' => :response,
        'lastModified' => :last_modified,
        'isHidden' => :hidden,
        'pendingState' => :state
      })
    end

    class AppReview < TunesBase
      attr_accessor :application
      attr_reader :rating
      attr_reader :id
      attr_reader :title
      attr_reader :review
      attr_reader :nickname
      attr_reader :store_front
      attr_reader :app_version
      attr_reader :last_modified
      attr_reader :helpful_views
      attr_reader :total_views
      attr_reader :edited
      attr_reader :raw_developer_response
      attr_accessor :developer_response

      attr_mapping({
        'id' => :id,
        'rating' => :rating,
        'title' => :title,
        'review' => :review,
        'nickname' => :nickname,
        'storeFront' => :store_front,
        'appVersionString' => :app_version,
        'lastModified' => :last_modified,
        'helpfulViews' => :helpful_views,
        'totalViews' => :total_views,
        'developerResponse' => :raw_developer_response,
        'edited' => :edited
      })
      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          obj = self.new(attrs)
          response_attrs = {}
          response_attrs = obj.raw_developer_response if obj.raw_developer_response
          response_attrs[:application] = obj.application
          response_attrs[:review_id] = obj.id
          obj.developer_response = DeveloperResponse.factory(response_attrs)
          return obj
        end
      end

      def responded?
        return true if raw_developer_response
        false
      end
    end

    class AppRatingSummary < TunesBase
      # @return (Integer) total number of reviews recevied
      attr_reader :review_count

      # @return (Integer) total number of ratings recevied
      attr_reader :rating_count

      # @return (Integer) total number of one star ratings recevied
      attr_reader :one_star_rating_count

      # @return (Integer) total number of two star ratings recevied
      attr_reader :two_star_rating_count

      # @return (Integer) total number of three star ratings recevied
      attr_reader :three_star_rating_count

      # @return (Integer) total number of four star ratings recevied
      attr_reader :four_star_rating_count

      # @return (Integer) total number of five star ratings recevied
      attr_reader :five_star_rating_count

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
        ((self.one_star_rating_count +
          (self.two_star_rating_count * 2) +
          (self.three_star_rating_count * 3) +
          (self.four_star_rating_count * 4) +
          (self.five_star_rating_count * 5)) / self.rating_count.to_f).round(2)
      end
    end
  end
end
