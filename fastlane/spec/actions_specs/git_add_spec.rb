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

        it "can not have pathspec parameter" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              git_add(path: 'myfile.txt', pathspec: 'Frameworks/*')
            end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneError)
        end
      end

      context "with pathspec parameter" do
        it "executes the correct git command" do
          allow(Fastlane::Actions).to receive(:sh).with("git add *.txt", anything).and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_add(pathspec: '*.txt')
          end").runner.execute(:test)
        end

        it "can not have path parameter" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              git_add(path: 'myfile.txt', pathspec: '*.txt')
            end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneError)
        end
      end

      context "without parameters" do
        it "executes the correct git command" do
          allow(Fastlane::Actions).to receive(:sh).with("git add .", anything).and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_add
          end").runner.execute(:test)
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
