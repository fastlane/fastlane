describe Fastlane do
  describe Fastlane::FastFile do
    describe "Team Name Action" do
      it "works as expected" do
        new_val = "abcdef"
        Fastlane::FastFile.new.parse("lane :test do
          team_name '#{new_val}'
        end").runner.execute(:test)

        [:FASTLANE_TEAM_NAME, :PRODUCE_TEAM_NAME].each do |current|
          expect(ENV[current.to_s]).to eq(new_val)
        end
      end

      it "raises an error if no team Name is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            team_name
          end").runner.execute(:test)
        end.to raise_error("Please pass your Team Name (e.g. team_name 'Felix Krause')")
      end
    end
  end
end
