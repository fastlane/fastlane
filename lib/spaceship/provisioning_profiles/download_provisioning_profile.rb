module Spaceship
  class Client
    # Downloads the given provisioning profile
    def download_provisioning_profile(profile)
      raise "Profile '#{profile}' is broken and does not contain an ID".red unless profile.id

      url = URL_DOWNLOAD_PROVISIONING_PROFILE + profile.id# + "&teamId=#{@team_id}"

      Helper.log.info "Downloading provisiong profile #{profile}".green
        response = Excon.get(url, headers: { "Cookie" => "myacinfo=#{@myacinfo}" } )

      raise "Error downloading provisioning profile.".red unless response.body.to_s.length > 0

      file_name = [profile.app.identifier, profile.distribution_method, 'mobileprovision'].join('.')
      path = File.join("/tmp", file_name)
      File.write(path, response.body)
      return path
    end
  end
end