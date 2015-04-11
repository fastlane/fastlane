module Spaceship
  class Client
    # Team selection
    def select_team
      response = unzip(Excon.post(URL_LIST_TEAMS, headers: { 'Cookie' => "myacinfo=#{@myacinfo}" }))
      content = Plist::parse_xml(response)

      team_to_use = nil
      
      raise "Your account is in no teams" unless content['teams'].count > 0
      team_to_use = content['teams'].first if content['teams'].count == 1

      while not team_to_use
        # Multiple teams, user has to select
        puts "Multiple teams found, please enter the number of the team you want to use: "
        content['teams'].each_with_index do |team, i|
          puts "#{i + 1}) #{team['teamId']} #{team['name']} (#{team['type']})".green
        end

        selected = gets.strip.to_i - 1
        team_to_use = content['teams'][selected] if selected >= 0
      end

      @team_information = team_to_use
      @team_id = team_to_use['teamId']
    end
  end
end

# Example response
# {"teams"=>
#   [{"status"=>"active",
#     "name"=>"SunApps GmbH",
#     "teamId"=>"5A997XSAAA",
#     "type"=>"Company/Organization",
#     "extendedTeamAttributes"=>{},
#     "teamAgent"=>{"teamMemberId"=>"5Y354CXU3A", "personId"=>1553424542, "firstName"=>"Felix", "lastName"=>"Krause", "email"=>"felix@krausefx.com", "developerStatus"=>"active"},
#     "memberships"=>
#      [{"membershipId"=>"HJ5WHYC5CE",
#        "membershipProductId"=>"ds1",
#        "name"=>"iOS Developer Program",
#        "status"=>"active",
#        "inDeviceResetWindow"=>false,
#        "inRenewalWindow"=>false,
#        "dateStart"=>#<DateTime: 2014-11-20T07:59:59+00:00 ((2456982j,28799s,0n),+0s,2299161j)>,
#        "dateExpire"=>#<DateTime: 2015-11-20T07:59:59+00:00 ((2457347j,28799s,0n),+0s,2299161j)>,
#        "platform"=>"ios",
#        "availableDeviceSlots"=>100}],
#     "currentTeamMember"=>
#      {"teamMemberId"=>"HQR8N4G84W",
#       "personId"=>1415355845,
#       "firstName"=>"Felix",
#       "lastName"=>"Krause",
#       "email"=>"deliver@krausefx.com",
#       "developerStatus"=>"active",
#       "privileges"=>{},
#       "roles"=>["TEAM_ADMIN"]}}],
#  "creationTimestamp"=>"2015-04-07T14:13:46Z",
#  "resultCode"=>0,
#  "userLocale"=>"en_US",
#  "protocolVersion"=>"QH65B2",
#  "requestUrl"=>"https://developerservices2.apple.com:443//services/QH65B2/listTeams.action",
#  "responseId"=>"d7fe23a8-7b13-45c9-8648-6a6ce6223848"}