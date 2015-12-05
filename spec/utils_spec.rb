describe Match do
  describe Match::Utils do
    describe "fill_environment" do
      it "pre-fills the environment" do
        uuid = "my_uuid #{Time.now.to_i}"
        values = {
          app_identifier: "tools.fastlane.app",
          type: "appstore"
        }
        result = Match::Utils.fill_environment(values, uuid)
        expect(result).to eq(uuid)

        item = ENV.find { |k, v| v == uuid }
        expect(item[0]).to eq("sigh_tools.fastlane.app_appstore")
        expect(item[1]).to eq(uuid)
      end
    end
  end
end
