describe Fastlane do
  describe Fastlane::FastFile do
    describe "sigh Action" do
      before do
        require 'sigh'

        @profile_path = "/tmp/something"
        expect(Sigh::Manager).to receive(:start).and_return(@profile_path)
      end

      it "properly stores the resulting path in the lane environment" do
        ENV["SIGH_UUID"] = "uuid"
        ENV["SIGH_NAME"] = "name"

        result = Fastlane::FastFile.new.parse("lane :test do
          sigh
        end").runner.execute(:test)

        expect(result).to eq('uuid')

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SIGH_PROFILE_PATH]).to eq(@profile_path)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SIGH_PROFILE_PATHS]).to eq([@profile_path])
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SIGH_PROFILE_TYPE]).to eq("app-store")
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SIGH_UUID]).to eq("uuid")
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SIGH_NAME]).to eq("name")
      end

      describe "The different profile types" do
        it "development" do
          Fastlane::FastFile.new.parse("lane :test do
            sigh(development: true)
          end").runner.execute(:test)
          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SIGH_PROFILE_TYPE]).to eq("development")
        end

        it "ad-hoc" do
          Fastlane::FastFile.new.parse("lane :test do
            sigh(adhoc: true)
          end").runner.execute(:test)
          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SIGH_PROFILE_TYPE]).to eq("ad-hoc")
        end

        it "enterprise" do
          ENV["SIGH_PROFILE_ENTERPRISE"] = "1"
          Fastlane::FastFile.new.parse("lane :test do
            sigh(adhoc: true)
          end").runner.execute(:test)
          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SIGH_PROFILE_TYPE]).to eq("enterprise")
          ENV.delete("SIGH_PROFILE_ENTERPRISE")
        end
      end
    end
  end
end
