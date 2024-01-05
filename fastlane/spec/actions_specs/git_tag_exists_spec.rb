describe Fastlane do
  describe Fastlane::FastFile do
    describe "git_tag_exists" do
      it "executes the correct git command" do
        allow(Fastlane::Actions).to receive(:sh)
          .with("git rev-parse -q --verify refs/tags/1.2.0", anything)
          .and_return("12345")
        result = Fastlane::FastFile.new.parse("lane :test do
          git_tag_exists(tag: '1.2.0')
        end").runner.execute(:test)
      end

      it "executes the correct git command remote" do
        allow(Fastlane::Actions).to receive(:sh)
          .with("git ls-remote -q --exit-code origin refs/tags/1.2.0", anything)
          .and_return("12345")
        result = Fastlane::FastFile.new.parse("lane :test do
          git_tag_exists(tag: '1.2.0', remote: true)
        end").runner.execute(:test)

        allow(Fastlane::Actions).to receive(:sh)
          .with("git ls-remote -q --exit-code huga refs/tags/1.2.0", anything)
          .and_return("12345")
        result = Fastlane::FastFile.new.parse("lane :test do
          git_tag_exists(tag: '1.2.0', remote: true, remote_name: 'huga')
        end").runner.execute(:test)
      end

      it "logs the command if verbose" do
        FastlaneSpec::Env.with_verbose(true) do
          allow(Fastlane::Actions).to receive(:sh)
            .with(anything, hash_including(log: true))
            .and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_tag_exists(tag: '1.2.0')
          end").runner.execute(:test)
        end
      end

      context("when the tag exists") do
        before do
          allow(Fastlane::Actions).to receive(:sh)
            .with("git rev-parse -q --verify refs/tags/1.2.0", hash_including(log: nil))
            .and_return("41215512353215321")
        end

        it "returns true" do
          result = Fastlane::FastFile.new.parse("lane :test do
            git_tag_exists(tag: '1.2.0')
          end").runner.execute(:test)

          expect(result).to eq(true)
        end
      end

      context("when the tag doesn't exist") do
        before do
          allow(Fastlane::Actions).to receive(:sh) { |command, params|
            expect(command).to eq('git rev-parse -q --verify refs/tags/1.2.0')
            expect(params[:log]).to be_nil
            params[:error_callback].call('error')
          }
        end

        it "returns true" do
          result = Fastlane::FastFile.new.parse("lane :test do
            git_tag_exists(tag: '1.2.0')
          end").runner.execute(:test)

          expect(result).to eq(false)
        end
      end
    end
  end
end
