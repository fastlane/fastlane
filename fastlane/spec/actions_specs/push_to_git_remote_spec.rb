describe Fastlane do
  describe Fastlane::FastFile do
    describe "Git Push to Remote Action" do
      before(:each) do
        allow(Fastlane::Actions).to receive(:git_branch).and_return("master")
      end

      it "runs git push with defaults" do
        result = Fastlane::FastFile.new.parse("lane :test do
            push_to_git_remote
          end").runner.execute(:test)

        expect(result).to eq("git push origin master:master --tags")
      end

      it "run git push with local_branch" do
        result = Fastlane::FastFile.new.parse("lane :test do
            push_to_git_remote(
              local_branch: 'staging'
            )
          end").runner.execute(:test)

        expect(result).to eq("git push origin staging:staging --tags")
      end

      it "run git push with local_branch and remote_branch" do
        result = Fastlane::FastFile.new.parse("lane :test do
            push_to_git_remote(
              local_branch: 'staging',
              remote_branch: 'production'
            )
          end").runner.execute(:test)

        expect(result).to eq("git push origin staging:production --tags")
      end

      it "runs git push with tags:false" do
        result = Fastlane::FastFile.new.parse("lane :test do
            push_to_git_remote(
              tags: false
            )
          end").runner.execute(:test)

        expect(result).to eq("git push origin master:master")
      end

      it "runs git push with force:true" do
        result = Fastlane::FastFile.new.parse("lane :test do
            push_to_git_remote(
              force: true
            )
          end").runner.execute(:test)

        expect(result).to eq("git push origin master:master --tags --force")
      end

      it "runs git push with force_with_lease:true" do
        result = Fastlane::FastFile.new.parse("lane :test do
            push_to_git_remote(
              force_with_lease: true
            )
          end").runner.execute(:test)

        expect(result).to eq("git push origin master:master --tags --force-with-lease")
      end

      it "runs git push with remote" do
        result = Fastlane::FastFile.new.parse("lane :test do
            push_to_git_remote(
              remote: 'not_github'
            )
          end").runner.execute(:test)

        expect(result).to eq("git push not_github master:master --tags")
      end

      it "runs git push with no_verify:true" do
        result = Fastlane::FastFile.new.parse("lane :test do
            push_to_git_remote(
              no_verify: true
            )
          end").runner.execute(:test)

        expect(result).to eq("git push origin master:master --tags --no-verify")
      end

      it "runs git push with set_upstream:true" do
        result = Fastlane::FastFile.new.parse("lane :test do
            push_to_git_remote(
              set_upstream: true
            )
          end").runner.execute(:test)

        expect(result).to eq("git push origin master:master --tags --set-upstream")
      end
    end
  end
end
