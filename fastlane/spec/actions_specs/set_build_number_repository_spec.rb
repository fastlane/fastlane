describe Fastlane do
  describe Fastlane::FastFile do
    context "set build number repository" do
      before do
        expect(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:run).and_return("asd123")
      end

      it "set build number" do
        result = Fastlane::FastFile.new.parse("lane :test do
            set_build_number_repository
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to match(/cd .* && agvtool new-version -all asd123/)
      end

      it "set build number" do
        result = Fastlane::FastFile.new.parse("lane :test do
            set_build_number_repository(
              use_hg_revision_number: true
            )
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to match(/cd .* && agvtool new-version -all asd123/)
      end
    end
  end
end
