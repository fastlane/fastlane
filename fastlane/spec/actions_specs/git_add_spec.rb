describe Fastlane do
  describe Fastlane::FastFile do
    describe "git_add" do
      before do
        allow(File).to receive(:exist?).with(anything).and_return(true)
      end

      context "with path parameter" do
        context "as string" do
          let(:path) { "myfile.txt" }

          it "executes the correct git command" do
            allow(Fastlane::Actions).to receive(:sh).with("git add #{path}", anything).and_return("")
            result = Fastlane::FastFile.new.parse("lane :test do
              git_add(path: '#{path}')
            end").runner.execute(:test)
          end
        end

        context "as array" do
          let(:path) { ["myfile.txt", "yourfile.txt"] }

          it "executes the correct git command" do
            allow(Fastlane::Actions).to receive(:sh).with("git add #{path[0]} #{path[1]}", anything).and_return("")
            result = Fastlane::FastFile.new.parse("lane :test do
              git_add(path: #{path})
            end").runner.execute(:test)
          end
        end
      end

      it "logs the command if verbose" do
        with_verbose(true) do
          allow(Fastlane::Actions).to receive(:sh).with(anything, { log: true }).and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_add(path: 'foo.bar')
          end").runner.execute(:test)
        end
      end
    end
  end
end
