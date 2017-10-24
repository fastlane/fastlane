describe Fastlane do
  describe Fastlane::FastFile do
    describe Fastlane::Actions::AppStoreBuildNumberAction::BuildNumber do
      it "Should works adding by int" do
        build_number = Fastlane::Actions::AppStoreBuildNumberAction::BuildNumber.new("3.9.1")

        result = build_number + 1

        expect(result).to eq(4)
      end

      it "Should sorted fine in mixed types" do
        build_number1 = Fastlane::Actions::AppStoreBuildNumberAction::BuildNumber.new("3")
        build_number2 = Fastlane::Actions::AppStoreBuildNumberAction::BuildNumber.new("3.9")
        build_number3 = Fastlane::Actions::AppStoreBuildNumberAction::BuildNumber.new("3.9.1")
        build_number4 = Fastlane::Actions::AppStoreBuildNumberAction::BuildNumber.new("39")

        build_numbers = [build_number1, build_number2, build_number3, build_number4]

        shuffled_build_numbers = build_numbers.shuffle
        result = shuffled_build_numbers.sort

        expect(result).to eq(build_numbers)
      end
    end

    describe Fastlane::Actions::AppStoreBuildNumberAction do
      it "Should return latest build in integer" do
        # Mock Builds
        build1 = OpenStruct.new
        build1.build_version = "3"

        build2 = OpenStruct.new
        build2.build_version = "2"

        builds = OpenStruct.new
        builds.builds = [build1, build2]

        # Mock App with Buildtrain
        spec_app = OpenStruct.new
        spec_app.build_trains = {
          "1.0" => builds
        }

        # Mock Spaceship
        expect(Spaceship::Tunes).to receive(:login).and_return(true)
        expect(Spaceship::Tunes).to receive(:select_team).and_return(true)
        expect(Spaceship::Application).to receive(:find).and_return(spec_app)

        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_build_number(username:'demo@demo.com', app_identifier: 'demo.app', live: false, version: '1.0')
        end").runner.execute(:test)

        expect(result).to eq(3)
      end

      it "Should return latest build in mixed type" do
        # Mock Builds
        build1 = OpenStruct.new
        build1.build_version = "3"

        build2 = OpenStruct.new
        build2.build_version = "2"

        build3 = OpenStruct.new
        build3.build_version = "3.9"

        builds = OpenStruct.new
        builds.builds = [build1, build2, build3]

        # Mock App with Buildtrain
        spec_app = OpenStruct.new
        spec_app.build_trains = {
          "1.0" => builds
        }

        # Mock Spaceship
        expect(Spaceship::Tunes).to receive(:login).and_return(true)
        expect(Spaceship::Tunes).to receive(:select_team).and_return(true)
        expect(Spaceship::Application).to receive(:find).and_return(spec_app)

        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_build_number(username:'demo@demo.com', app_identifier: 'demo.app', live: false, version: '1.0')
        end").runner.execute(:test)

        expect(result).to eq(3.9)
      end
    end
  end
end
