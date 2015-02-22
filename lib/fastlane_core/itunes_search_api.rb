require 'open-uri'

module FastlaneCore
  # A wrapper around the Apple iTunes Search API to access app information like
  # the app identifier of an app.
  class ItunesSearchApi

    # Fetch all information you can get from a specific AppleID of an app
    # @param id (int) The AppleID of the given app. This usually consists of 9 digits.
    # @return (Hash) the response of the first result from Apple (https://itunes.apple.com/lookup?id=284882215)
    # @example Response of Facebook App: https://itunes.apple.com/lookup?id=284882215
    #  { 
    #   ...
    #   artistName: "Facebook, Inc.",
    #   price: 0,
    #   version: "14.9",
    #   ...
    #  }
    def self.fetch(id)
      # Example: https://itunes.apple.com/lookup?id=284882215
      fetch_url("https://itunes.apple.com/lookup?id=#{id.to_s}")
    end

    def self.fetch_by_identifier(app_identifier)
      # Example: http://itunes.apple.com/lookup?bundleId=net.sunapps.1
      fetch_url("https://itunes.apple.com/lookup?bundleId=#{app_identifier}")
    end
      

    # This method only fetches the bundle identifier of a given app
    # @param id (int) The AppleID of the given app. This usually consists of 9 digits.
    # @return (String) the Bundle identifier of the app
    def self.fetch_bundle_identifier(id)
      self.fetch(id)['bundleId']
    end

    private
      def self.fetch_url(url)
        response = JSON.parse(open(url).read)
        return nil if response['resultCount'] == 0

        return response['results'].first
      rescue
        Helper.log.error "Could not find object '#{url}' using the iTunes API"
        nil
      end
  end
end