require 'spec_helper'

describe Spaceship do
  describe "Apps" do
    before do
      @client = Spaceship::Client.new
    end

    describe "successfully loads and parses all apps" do
      before do
        @apps = @client.apps
      end

      it "the number is correct" do
        expect(@apps.count).to eq(5)
      end

      it "parses app correctly" do
        app = @apps.first

        expect(app.app_id).to eq("B7JBD8LHAA")
        expect(app.name).to eq("The App Name")
        expect(app.platform).to eq("ios")
        expect(app.prefix).to eq("5A997XSHK2")
        expect(app.identifier).to eq("net.sunapps.151")
        expect(app.is_wildcard).to eq(false)
      end

      it "parses wildcard apps correctly" do
        app = @apps.last

        expect(app.app_id).to eq("L42E9BTRAA")
        expect(app.name).to eq("SunApps")
        expect(app.platform).to eq("ios")
        expect(app.prefix).to eq("5A997XSHK2")
        expect(app.identifier).to eq("net.sunapps.*")
        expect(app.is_wildcard).to eq(true)
      end
    end


    describe "Filter app based on app identifier" do

      it "works with specific App IDs" do
        app = @client.fetch_app("net.sunapps.151")
        expect(app.app_id).to eq("B7JBD8LHAA")
        expect(app.is_wildcard).to eq(false)
      end

      it "works with wilcard App IDs" do
        app = @client.fetch_app("net.sunapps.*")
        expect(app.app_id).to eq("L42E9BTRAA")
        expect(app.is_wildcard).to eq(true)
      end

      it "throws exception if app ID wasn't found" do
        begin
          apps = @client.fetch_app("asdfasdf")
          raise "Not working test"
        rescue => ex
          expect(ex.to_s).to include("Couldn't find app with bundle identifier 'asdfasdf'. Available")
        end
      end

    end
  end
end