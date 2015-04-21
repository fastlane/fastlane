module Spaceship
  class Certificate < Struct.new(:client, :id, :name, :status, :created, :expires, :owner_type, :owner_name, :owner_id, :is_push, :type_id)
    # Parse the server response
    def self.create(client, hash)
      Certificate.new(
        client,
        hash['certificateId'],
        hash['name'],
        hash['statusString'],
        hash['dateCreated'],
        hash['expirationDate'],
        hash['ownerType'],
        hash['ownerName'],
        hash['ownerId'],
        hash['ownerType'] == 'bundle', # certificates have the type 'team' or 'teamMember'
        hash['certificateTypeDisplayId']
      )
    end

    def to_s
      [self.name, self.owner_type.capitalize, self.id].join(" - ")
    end

    def download
      client.download(id, type_id)
    end

    # Examples

    # Signing Certificate
    # id="LHNT9C2AAA",
    # name="SunApps GmbH",
    # status="Issued",
    # created="2015-02-10T23:54:20Z",
    # expires="2016-02-10T23:44:20Z",
    # owner_type="team",
    # owner_name="SunApps GmbH",
    # owner_id="5A997XSAAA",
    # is_push=false

    # Push
    # id="7DHTD3QAAA",
    # name="net.sunapps.14",
    # status="Issued",
    # created="2014-05-18T13:13:50Z",
    # expires="2015-05-18T13:03:50Z",
    # owner_type="bundle",
    # owner_name="Your App Name",
    # owner_id="Z84NQ3QAAA",
    # is_push=true
  end

  class Client
    # @param types Take a look at profiles_types.rb (optional)
    def certificates(types = nil)
      types ||= ProfileTypes.all_profile_types.join(",")

      url = URL_LIST_CERTIFICATES + "teamId=#{@team_id}&types=#{types}"

      response = JSON.parse(request(url,
                    body: URI.encode_www_form(
                      pageSize: 5000,
                      pageNumber: 1,
                      sort: "name=asc"
                    )
                   ).with_auth.post.body)

      return response['certRequests'].collect do |current|
        Certificate.create(self, current)
      end
    end

    def download(id, type)
      url = 'https://developer.apple.com/account/ios/certificate/certificateContentDownload.action'
      request(url, query: {
        displayId: id,
        type: type
      }).with_auth.get.body
    end
  end
end
