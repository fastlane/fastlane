describe Fastlane do
  describe Fastlane::FastFile do
    describe "ensure_no_debug_code" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end

      it "handles extension and extensions parameters correctly" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_no_debug_code(text: 'pry', path: '.', extension: 'rb', extensions: ['m', 'h'])
        end").runner.execute(:test)
        expect(result).to eq("grep -RE pry #{File.absolute_path('./').shellescape} --include=\\*.{rb,m,h}")
      end

      it "handles the extension parameter correctly" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_no_debug_code(text: 'pry', path: '.', extension: 'rb')
        end").runner.execute(:test)
        expect(result).to eq("grep -RE pry #{File.absolute_path('./').shellescape} --include=\\*.rb")
      end

      it "handles the extensions parameter with multiple elements correctly" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_no_debug_code(text: 'pry', path: '.', extensions: ['m', 'h'])
        end").runner.execute(:test)
        expect(result).to eq("grep -RE pry #{File.absolute_path('./').shellescape} --include=\\*.{m,h}")
      end

      it "handles the extensions parameter with a single element correctly" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_no_debug_code(text: 'pry', path: '.', extensions: ['m'])
        end").runner.execute(:test)
        expect(result).to eq("grep -RE pry #{File.absolute_path('./').shellescape} --include=\\*.m")
      end

      it "handles the extensions parameter with no elements correctly" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_no_debug_code(text: 'pry', path: '.', extensions: [])
        end").runner.execute(:test)
        expect(result).to eq("grep -RE pry #{File.absolute_path('./').shellescape}")
      end

      it "handles no extension or extensions parameters" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_no_debug_code(text: 'pry', path: '.')
        end").runner.execute(:test)
        expect(result).to eq("grep -RE pry #{File.absolute_path('./').shellescape}")
      end

      it "keeps a pattern and a path with an apostrophe and a space as one argument each" do
        Dir.mktmpdir do |dir|
          path = File.join(dir, "Kaldi's Kafe")
          FileUtils.mkdir_p(path)
          result = Fastlane::FastFile.new.parse("lane :test do
            ensure_no_debug_code(text: \"don't ship\", path: #{path.inspect})
          end").runner.execute(:test)

          expect(Shellwords.split(result)).to eq(["grep", "-RE", "don't ship", File.absolute_path(path)])
        end
      end

      it "passes the exclude pattern to grep instead of letting the shell expand it" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_no_debug_code(text: 'pry', path: '.', exclude: '*.md')
        end").runner.execute(:test)

        expect(result).to end_with(' --exclude \*.md')
      end

      it "handles the exclude_dirs parameter with no elements correctly" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_no_debug_code(text: 'pry', path: '.', exclude_dirs: [])
        end").runner.execute(:test)
        expect(result).to eq("grep -RE pry #{File.absolute_path('./').shellescape}")
      end

      it "handles the exclude_dirs parameter with a single element correctly" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_no_debug_code(text: 'pry', path: '.', exclude_dirs: ['.bundle'])
        end").runner.execute(:test)
        expect(result).to eq("grep -RE pry #{File.absolute_path('./').shellescape} --exclude-dir .bundle")
      end

      it "shellescapes the exclude_dirs correctly" do
        directory = "My Dir"
        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_no_debug_code(text: 'pry', path: '.', exclude_dirs: ['#{directory}'])
        end").runner.execute(:test)
        expect(result).to eq("grep -RE pry #{File.absolute_path('./').shellescape} --exclude-dir #{directory.shellescape}")
      end

      it "handles the exclude_dirs parameter with multiple elements correctly" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_no_debug_code(text: 'pry', path: '.', exclude_dirs: ['.bundle', 'Packages/'])
        end").runner.execute(:test)
        expect(result).to eq("grep -RE pry #{File.absolute_path('./').shellescape} --exclude-dir .bundle --exclude-dir Packages/")
      end
    end
  end
end
