module Fastlane::ActionSets::Amazon
  # Describes a version of an app update; the basis for all modifications
  # against the Amazon App Submission API.
  class Edit
    # @return [String] The unique identifier of the edit
    attr_reader :id
    # @return [String] The status of the edit; `LIVE`, `IN_PROGRESS`, etc.
    attr_reader :status

    # @param [Hash] json
    def initialize(json)
      @id = json['id']
      @status = json['status']
    end

    # @param [Edit] other
    # @return [Boolean]
    def ==(other)
      id == other.id && status == other.status
    end

    def to_s
      "<Fastlane::ActionSets::Amazon::Edit:#{object_id} id=>\"#{id}\" status=>\"#{status}\">"
    end
  end
end
