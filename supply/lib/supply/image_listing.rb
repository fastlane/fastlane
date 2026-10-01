module Supply
  class ImageListing
    attr_reader :id
    attr_reader :sha1
    attr_reader :sha256
    attr_reader :url

    def initialize(id, sha1, sha256, url)
      @id = id
      @sha1 = sha1
      @sha256 = sha256
      @url = url
    end
  end
end
