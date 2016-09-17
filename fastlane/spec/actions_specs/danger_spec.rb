describe Fastlane do
  describe Fastlane::FastFile do
    describe "danger integration" do
      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger")
      end

      it "no bundle exec" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(use_bundle_exec: false)
        end").runner.execute(:test)

        expect(result).to eq("danger")
      end

      it "appends verbose" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(verbose: true)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --verbose")
      end

      it "sets github token" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(github_api_token: '1234')
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger")
        expect(ENV['DANGER_GITHUB_API_TOKEN']).to eq("1234")
      end

      it "appends danger_id" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(danger_id: 'unit-tests')
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --danger_id=unit-tests")
      end

      it "appends dangerfile" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(dangerfile: 'test/OtherDangerfile')
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --dangerfile=test/OtherDangerfile")
      end
    end
  end
end
