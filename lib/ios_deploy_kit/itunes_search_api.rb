require 'open-uri'

module IosDeployKit
  class ItunesSearchApi
    def self.fetch(id)
      # Example: https://itunes.apple.com/lookup?id=284882215

      response = JSON.parse(open("https://itunes.apple.com/lookup?id=#{id}").read)
      return nil if response['resultCount'] == 0

      return response['results'].first
    rescue
      Helper.log.error "Could not find object '#{id}' using the iTunes API"
      nil
    end

    def self.fetch_bundle_identifier(id)
      self.fetch(id)['bundleId']
    end
  end
end