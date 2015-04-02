module FastlaneCore  
  # Find the Apple ID based on the App Identifier
  class ItunesConnect
    LIST_APPLE_IDS_URL = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/manageyourapps/summary"
    def find_apple_id(app_identifier)
      login

      apps = JSON.parse(page.evaluate_script("$.ajax({type: 'GET', url: '#{LIST_APPLE_IDS_URL}', async: false})")['responseText'])['data']

      return apps['summaries'].find { |v| v['bundleId'] == app_identifier }['adamId'].to_i
    rescue => ex
      # Do nothing right now...
    end
  end
end