module Fastlane::ActionSets::Amazon
  # Describes metadata for an APK.
  class APKMetadata
    # @return [String] The unique identifier of the APK
    attr_reader :id
    # @return [String] The internal name of the APK (not shown to customers)
    attr_reader :name
    # @return [String] The version code assigned to the APK (by Amazon)
    attr_reader :version_code

    # @param [Hash] json
    def initialize(json)
      @id = json['id']
      @name = json['name']
      @version_code = json['versionCode']
    end

    # @param [APKMetadata] other
    # @return [Boolean]
    def ==(other)
      id == other.id && name == other.name && version_code == other.version_code
    end

    def to_s
      "<Fastlane::ActionSets::Amazon::APKMetadata:#{object_id} id=>\"#{id}\" name=>\"#{name}\" version_code=>\"#{version_code}\">"
    end
  end
end
