require_relative 'developer_response'

module Spaceship
  module Tunes
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
        'edited' => :edited,
        'developerResponse' => :raw_developer_response
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
  end
end
