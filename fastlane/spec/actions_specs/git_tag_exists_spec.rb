describe Fastlane do
  describe Fastlane::FastFile do
    describe "git_tag_exists" do
      it "executes the correct git command" do
        allow(Fastlane::Actions).to receive(:sh).with("git rev-parse -q --verify refs/tags/1.2.0 || true", anything).and_return("")
        result = Fastlane::FastFile.new.parse("lane :test do
          git_tag_exists(tag: '1.2.0')
        end").runner.execute(:test)
      end

      it "logs the command if verbose" do
        with_verbose(true) do
          allow(Fastlane::Actions).to receive(:sh).with(anything, { log: true }).and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_tag_exists(tag: '1.2.0')
          end").runner.execute(:test)
        end
      end

      context("when the tag exists") do
        before do
          allow(Fastlane::Actions).to receive(:sh).with("git rev-parse -q --verify refs/tags/1.2.0 || true", { log: nil }).and_return("41215512353215321")
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
          allow(Fastlane::Actions).to receive(:sh).with("git rev-parse -q --verify refs/tags/1.2.0 || true", { log: nil }).and_return("")
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
