require 'spec_helper'

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
