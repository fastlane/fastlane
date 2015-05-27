module Spaceship
  class Client
    class UserInterface
      # Shows the UI to select a team
      # @example teams value:
      #  [{"status"=>"active",
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

        user_team = (ENV['FASTLANE_TEAM_ID'] || '').strip
        if user_team
          # User provided a value, let's see if it's valid
          puts "Looking for team with ID '#{user_team}'"
          teams.each_with_index do |team, i|
            return user_team if (team['teamId'].strip == user_team)
          end
          puts "Couldn't find team with ID '#{user_team}'"
        end


        return teams[0]['teamId'] if teams.count == 1 # user is just in one team


        # User Selection
        loop do
          # Multiple teams, user has to select
          puts "Multiple teams found, please enter the number of the team you want to use: "
          teams.each_with_index do |team, i|
            puts "#{i + 1}) #{team['teamId']} #{team['name']} (#{team['type']})"
          end

          selected = ($stdin.gets || '').strip.to_i - 1
          team_to_use = teams[selected] if selected >= 0

          return team_to_use['teamId'] if team_to_use
        end
      end
    end
  end
end