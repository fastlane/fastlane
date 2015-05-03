describe Fastlane do
  describe Fastlane::FastFile do
    describe "Hall Action" do
      before :each do
        ENV['HALL_GROUP_API_TOKEN'] = '123123'
      end

      it "raises an error if no group API token is given" do
        ENV.delete 'HALL_GROUP_API_TOKEN'
        expect {
          Fastlane::FastFile.new.parse("lane :test do 
            hall
          end").runner.execute(:test)
        }.to raise_exception('No HALL_GROUP_API_TOKEN given.'.red)
      end

      it "works with valid parameters" do
        title = "fastlane"
        message = "Custom Message"
        picture = "Picture"
        lane_name = "lane_name"
        group_api_token = ENV['HALL_GROUP_API_TOKEN']

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        require 'fastlane/actions/hall'
        arguments = Fastlane::ConfigurationHelper.parse(Fastlane::Actions::HallAction, {
          title: title,
          message: message,
          picture: picture
        })

        url, body = Fastlane::Actions::HallAction.run(arguments)

        expect(url).to eq("https://hall.com/api/1/services/generic/#{group_api_token}")
        expect(body["title"]).to eq(title)
        expect(body["message"]).to eq(message)
        expect(body["picture"]).to eq(picture)
      end
    end
  end
end
