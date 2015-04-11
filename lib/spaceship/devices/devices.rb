module Spaceship
  class Device < Struct.new(:client, :id, :name, :udid, :platform, :status)
    # Parse the server response
    def self.create(client, hash)
      Device.new(
        client,
        hash['deviceId'],
        hash['name'],
        hash['deviceNumber'],
        hash['devicePlatform'],
        hash['status']
      )
    end

    def to_s
      [self.name, self.udid].join(" - ")
    end

    # Example
    # id="GD25LDGN99",
    # name="Felix Krause's iPhone 6",
    # udid="9b9273fb85b5dd5f4dd9b9273fb85b5dd5f4dd",
    # platform="ios",
    # status="c">,
  end


  class Client
    def devices
      return @devices if @devices

      response = unzip(Excon.post(URL_LIST_DEVICES, 
        headers: { 'Cookie' => "myacinfo=#{@myacinfo}" },
        body: "teamId=#{@team_id}"))
      results = Plist::parse_xml(response)
      
      @devices = results['devices'].collect do |current|
        Device.create(self, current)
      end
    end
  end
end