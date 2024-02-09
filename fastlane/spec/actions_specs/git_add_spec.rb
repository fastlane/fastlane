describe Fastlane do
  describe Fastlane::FastFile do
    describe "git_add" do
      before do
        allow(File).to receive(:exist?).with(anything).and_return(true)
      end

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

      context "as string with spaces in name" do
        let(:path) { "my file.txt" }

        it "executes the correct git command" do
          allow(Fastlane::Actions).to receive(:sh).with("git add #{path.shellescape}", anything).and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_add(path: '#{path}')
          end").runner.execute(:test)
        end
      end

      context "as array with spaces in name and directory" do
        let(:path) { ["my file.txt", "some dir/your file.txt"] }

        it "executes the correct git command" do
          allow(Fastlane::Actions).to receive(:sh).with("git add #{path[0].shellescape} #{path[1].shellescape}", anything).and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_add(path: #{path})
          end").runner.execute(:test)
        end
      end

      context "as string with wildcards" do
        it "executes the correct git command" do
          allow(Fastlane::Actions).to receive(:sh).with("git add *.txt", anything).and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_add(path: '*.txt', shell_escape: false)
          end").runner.execute(:test)
        end
      end

      context "as array with wildcards" do
        let(:path) { ["*.h", "*.m"] }

        it "executes the correct git command" do
          allow(Fastlane::Actions).to receive(:sh).with("git add *.h *.m", anything).and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_add(path: #{path}, shell_escape: false)
          end").runner.execute(:test)
        end
      end

      context "as string with force option" do
        let(:path) { "myfile.txt" }

        it "executes the correct git command" do
          allow(Fastlane::Actions).to receive(:sh).with("git add --force #{path}", anything).and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_add(path: '#{path}', force: true)
          end").runner.execute(:test)
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
        FastlaneSpec::Env.with_verbose(true) do
          allow(Fastlane::Actions).to receive(:sh).with(anything, { log: true }).and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_add(path: 'foo.bar')
          end").runner.execute(:test)
        end
      end

      it "passes the deprecated pathspec parameter to path parameter" do
        FastlaneSpec::Env.with_verbose(true) do
          allow(Fastlane::Actions).to receive(:sh).with(anything, { log: true }).and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            git_add(pathspec: 'myfile.txt')
          end").runner.execute(:test)
        end
      end

      it "cannot have both path and pathspec parameters" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            git_add(path: 'myfile.txt', pathspec: '*.txt')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end
    end
  end
end
