module Supply
  class ReleaseListing
    attr_accessor :track
    attr_accessor :version
    attr_accessor :versioncodes
    attr_accessor :language
    attr_accessor :release_notes

    # Initializes the release listing with the current listing if available
    def initialize(track, version, versioncodes, language, text)
      self.track = track
      self.version = version
      self.versioncodes = versioncodes
      self.language = language
      self.release_notes = text
    end
  end
end
