describe Fastlane do
  describe Fastlane::FastFile do
    context "set build number repository" do
      before do
        expect(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:run).and_return("asd123")
      end

      it "set build number without xcodeproj" do
        expect(Fastlane::Actions::IncrementBuildNumberAction).to receive(:run)
          .with(build_number: "asd123", xcodeproj: nil)

        Fastlane::FastFile.new.parse("lane :test do
            set_build_number_repository
        end").runner.execute(:test)
      end

      it "set build number with use_hg_revision_number" do
        expect(Fastlane::Actions::IncrementBuildNumberAction).to receive(:run)
          .with(build_number: "asd123", xcodeproj: nil)

        Fastlane::FastFile.new.parse("lane :test do
            set_build_number_repository(
              use_hg_revision_number: true
            )
        end").runner.execute(:test)
      end

      it "set build number with explicit xcodeproj" do
        expect(Fastlane::Actions::IncrementBuildNumberAction).to receive(:run)
          .with(build_number: "asd123", xcodeproj: "asd123/project.xcodeproj")

        Fastlane::FastFile.new.parse("lane :test do
            set_build_number_repository(
              xcodeproj: 'asd123/project.xcodeproj'
            )
        end").runner.execute(:test)
      end
    end
  end
end
