describe Fastlane do
  describe Fastlane::FastFile do
    context "set build number repository" do
      before do
        allow(Fastlane::Actions::IncrementBuildNumberAction).to receive(:system).with(/agvtool/).and_return(true)
        expect(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:run).and_return("asd123")
      end

      it "set build number without xcodeproj" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool new[-]version [-]all asd123 && cd [-]/)
          .and_return("")

        result = Fastlane::FastFile.new.parse("lane :test do
            set_build_number_repository
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq('asd123')
      end

      it "set build number with use_hg_revision_number" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool new[-]version [-]all asd123 && cd [-]/)
          .and_return("")

        result = Fastlane::FastFile.new.parse("lane :test do
            set_build_number_repository(
              use_hg_revision_number: true
            )
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq('asd123')
      end

      it "set build number with explicit xcodeproj" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool new[-]version [-]all asd123 && cd [-]/)
          .and_return("")

        result = Fastlane::FastFile.new.parse("lane :test do
            set_build_number_repository(
              xcodeproj: 'asd123/project.xcodeproj'
            )
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq('asd123')
      end
    end
  end
end
