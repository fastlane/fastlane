module Spaceship
  class Client
    class UserInterface
      # Shows the UI to select a team
      # Example `teams` value:
      # => [{"status"=>"active",
      #   "teamId"=>"5A997XAAAA",
      #   "type"=>"Company/Organization",
      #   "extendedTeamAttributes"=>{},
      #   "teamAgent"=>{
      #       "personId"=>15534241111, 
      #       "firstName"=>"Felix", 
      #       "lastName"=>"Krause", 
      #       "email"=>"spaceship@krausefx.com", 
      #       "developerStatus"=>"active", 
      #       "teamMemberId"=>"5Y354CXAAA"},
      #   "memberships"=>
      #    [{"membershipId"=>"HJ5WHYC5CE",
      #      "membershipProductId"=>"ds1",
      #      "status"=>"active",
      #      "inDeviceResetWindow"=>false,
      #      "inRenewalWindow"=>false,
      #      "dateStart"=>"11/20/14 07:59",
      #      "dateExpire"=>"11/20/15 07:59",
      #      "platform"=>"ios",
      #      "availableDeviceSlots"=>100,
      #      "name"=>"iOS Developer Program"}],
      #   "currentTeamMember"=>
      #    {"personId"=>nil, "firstName"=>nil, "lastName"=>nil, "email"=>nil, "developerStatus"=>nil, "privileges"=>{}, "roles"=>["TEAM_ADMIN"], "teamMemberId"=>"HQR8N4GAAA"},
      #   "name"=>"Company GmbH"},
      #     {...}
      #   ]

      def select_team
        teams = client.teams

        raise "Your account is in no teams" if teams.count == 0
        return teams[0]['teamId'] if teams.count == 1 # user is just in one team

        loop do
          # Multiple teams, user has to select
          puts "Multiple teams found, please enter the number of the team you want to use: ".yellow
          teams.each_with_index do |team, i|
            puts "#{i + 1}) #{team['teamId']} #{team['name']} (#{team['type']})".green
          end

          selected = $stdin.gets.strip.to_i - 1
          team_to_use = teams[selected] if selected >= 0

          return team_to_use['teamId'] if team_to_use
        end
      end
    end
  end
end