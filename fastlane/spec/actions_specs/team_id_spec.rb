describe Fastlane do
  describe Fastlane::FastFile do
    describe "Team ID Action" do
      it "works as expected" do
        new_val = "abcdef"
        Fastlane::FastFile.new.parse("lane :test do
          team_id '#{new_val}'
        end").runner.execute(:test)

        [:CERT_TEAM_ID, :SIGH_TEAM_ID, :PEM_TEAM_ID, :PRODUCE_TEAM_ID, :SIGH_TEAM_ID, :FASTLANE_TEAM_ID].each do |current|
          expect(ENV[current.to_s]).to eq(new_val)
        end
      end

      it "raises an error if no team ID is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            team_id
          end").runner.execute(:test)
        end.to raise_error("Please pass your Team ID (e.g. team_id 'Q2CBPK58CA')")
      end
    end
  end
end
