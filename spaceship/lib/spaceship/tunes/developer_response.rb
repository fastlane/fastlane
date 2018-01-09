require_relative 'tunes_base'

module Spaceship
  module Tunes
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
  end
end
