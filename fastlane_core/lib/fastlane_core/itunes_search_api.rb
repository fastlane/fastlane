require 'open-uri'

require_relative 'ui/ui'

module FastlaneCore
  # A wrapper around the Apple iTunes Search API to access app information like
  # the app identifier of an app.
  class ItunesSearchApi
    # Fetch all information you can get from a specific AppleID of an app
    # @param id (int) The AppleID of the given app. This usually consists of 9 digits.
    # @param country (string) The optional ISO-2A country code
    # @return (Hash) the response of the first result from Apple (https://itunes.apple.com/lookup?id=284882215[&country=FR])
    # @example Response of Facebook App: https://itunes.apple.com/lookup?id=284882215[&country=FR]
    #  {
    #   ...
    #   artistName: "Facebook, Inc.",
    #   price: 0,
    #   version: "14.9",
    #   ...
    #  }
    def self.fetch(id, country = nil)
      # Example: https://itunes.apple.com/lookup?id=284882215[&country=FR]
      suffix = country.nil? ? nil : "&country=#{country}"
      fetch_url("https://itunes.apple.com/lookup?id=#{id}#{suffix}")
    end

    def self.fetch_by_identifier(app_identifier, country = nil)
      # Example: http://itunes.apple.com/lookup?bundleId=net.sunapps.1[&country=FR]
      suffix = country.nil? ? nil : "&country=#{country}"
      fetch_url("https://itunes.apple.com/lookup?bundleId=#{app_identifier}#{suffix}")
    end

    # This method only fetches the bundle identifier of a given app
    # @param id (int) The AppleID of the given app. This usually consists of 9 digits.
    # @return (String) the Bundle identifier of the app
    def self.fetch_bundle_identifier(id)
      self.fetch(id)['bundleId']
    end

    def self.fetch_url(url)
      response = JSON.parse(open(url).read)
      return nil if response['resultCount'] == 0

      return response['results'].first
    rescue
      UI.error("Could not find object '#{url}' using the iTunes API")
      nil
    end
  end
end
