module Supply
  class ApkListing
    attr_accessor :recent_changes
    attr_accessor :language
    attr_accessor :apk_version_code

    # Initializes the apk listing with the current listing if available
    def initialize(recent_changes, language, apk_version_code)
      self.recent_changes = recent_changes
      self.language = language
      self.apk_version_code = apk_version_code
    end
  end
end
