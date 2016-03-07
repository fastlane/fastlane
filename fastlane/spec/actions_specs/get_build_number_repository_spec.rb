describe Fastlane do
  describe Fastlane::FastFile do
    context "SVN repository" do
      before do
        expect(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_svn?).and_return(true)
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_git_svn?).and_return(false)
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_git?).and_return(false)
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_hg?).and_return(false)
      end

      it "get SVN build number" do
        result = Fastlane::FastFile.new.parse("lane :test do
            get_build_number_repository
        end").runner.execute(:test)

        expect(result).to eq('svn info | grep Revision | egrep -o "[0-9]+"')
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER_REPOSITORY]).to eq('svn info | grep Revision | egrep -o "[0-9]+"')
      end
    end

    context "GIT-SVN repository" do
      before do
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_svn?).and_return(false)
        expect(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_git_svn?).and_return(true)
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_git?).and_return(false)
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_hg?).and_return(false)
      end

      it "get GIT-SVN build number" do
        result = Fastlane::FastFile.new.parse("lane :test do
            get_build_number_repository
        end").runner.execute(:test)

        expect(result).to eq('git svn info | grep Revision | egrep -o "[0-9]+"')
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER_REPOSITORY]).to eq('git svn info | grep Revision | egrep -o "[0-9]+"')
      end
    end

    context "GIT repository" do
      before do
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_svn?).and_return(false)
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_git_svn?).and_return(false)
        expect(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_git?).and_return(true)
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_hg?).and_return(false)
      end

      it "get GIT build number" do
        result = Fastlane::FastFile.new.parse("lane :test do
            get_build_number_repository
        end").runner.execute(:test)

        expect(result).to eq('git rev-parse --short HEAD')
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER_REPOSITORY]).to eq('git rev-parse --short HEAD')
      end
    end

    context "Mercurial repository" do
      before do
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_svn?).and_return(false)
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_git_svn?).and_return(false)
        allow(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_git?).and_return(false)
        expect(Fastlane::Actions::GetBuildNumberRepositoryAction).to receive(:is_hg?).and_return(true)
      end

      it "get HG build number" do
        result = Fastlane::FastFile.new.parse("lane :test do
            get_build_number_repository
        end").runner.execute(:test)

        expect(result).to eq('hg parent --template "{node|short}"')
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER_REPOSITORY]).to eq('hg parent --template "{node|short}"')
      end

      it "get HG revision number" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_build_number_repository(
            use_hg_revision_number: true
          )
        end").runner.execute(:test)

        expect(result).to eq('hg parent --template {rev}')
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER_REPOSITORY]).to eq('hg parent --template {rev}')
      end
    end
  end
end
