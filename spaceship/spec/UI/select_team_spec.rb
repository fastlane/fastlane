describe Spaceship::Client do
  describe "UI" do
    describe "#select_team" do
      include_examples "common spaceship login"

      subject { Spaceship.client }

      before do
        Spaceship.login
        client = Spaceship.client
      end

      it "uses the first team if there is only one" do
        expect(subject.select_team).to eq("XXXXXXXXXX")
      end

      describe "Multiple Teams" do
        before do
          PortalStubbing.adp_stub_multiple_teams
        end

        it "Lets the user select the team if in multiple teams" do
          allow($stdin).to receive(:gets).and_return("2")
          expect(Spaceship::Client::UserInterface).to receive(:interactive?).and_return(true)
          expect(subject.select_team).to eq("XXXXXXXXXX") # a different team
        end

        it "Falls back to user selection if team wasn't found" do
          ENV["FASTLANE_TEAM_ID"] = "Not Here"
          expect(Spaceship::Client::UserInterface).to receive(:interactive?).and_return(true)
          allow($stdin).to receive(:gets).and_return("2")
          expect(subject.select_team).to eq("XXXXXXXXXX") # a different team
        end

        it "Uses the specific team (1/2) using environment variables" do
          ENV["FASTLANE_TEAM_ID"] = "SecondTeam"
          expect(subject.select_team).to eq("SecondTeam") # a different team
        end

        it "Uses the specific team (2/2) using environment variables" do
          ENV["FASTLANE_TEAM_ID"] = "XXXXXXXXXX"
          expect(subject.select_team).to eq("XXXXXXXXXX") # a different team
        end

        it "Let's the user specify the team name using environment variables" do
          ENV["FASTLANE_TEAM_NAME"] = "SecondTeamProfiName"
          expect(subject.select_team).to eq("SecondTeam")
        end

        it "Uses the specific team (1/2) using method parameters" do
          expect(subject.select_team(team_id: "SecondTeam")).to eq("SecondTeam") # a different team
        end

        it "Uses the specific team (2/2) using method parameters" do
          expect(subject.select_team(team_id: "XXXXXXXXXX")).to eq("XXXXXXXXXX") # a different team
        end

        it "Let's the user specify the team name using method parameters" do
          expect(subject.select_team(team_name: "SecondTeamProfiName")).to eq("SecondTeam")
        end

        it "Strips out spaces before and after the team name" do
          ENV["FASTLANE_TEAM_NAME"] = "   SecondTeamProfiName   "
          expect(subject.select_team).to eq("SecondTeam")
        end

        it "Asks for the team if the name couldn't be found (pick first)" do
          ENV["FASTLANE_TEAM_NAME"] = "NotExistent"
          expect(Spaceship::Client::UserInterface).to receive(:interactive?).and_return(true)
          allow($stdin).to receive(:gets).and_return("1")
          expect(subject.select_team).to eq("SecondTeam")
        end

        it "Asks for the team if the name couldn't be found (pick last)" do
          ENV["FASTLANE_TEAM_NAME"] = "NotExistent"
          expect(Spaceship::Client::UserInterface).to receive(:interactive?).and_return(true)
          allow($stdin).to receive(:gets).and_return("2")
          expect(subject.select_team).to eq("XXXXXXXXXX")
        end

        it "Raises an Error if shell is non interactive" do
          expect(Spaceship::Client::UserInterface).to receive(:interactive?).and_return(false)
          expect do
            subject.select_team
          end.to raise_error("Multiple Teams found; unable to choose, terminal not interactive!")
        end

        after do
          ENV.delete("FASTLANE_TEAM_ID")
          ENV.delete("FASTLANE_TEAM_NAME")
        end
      end
    end
  end
end
