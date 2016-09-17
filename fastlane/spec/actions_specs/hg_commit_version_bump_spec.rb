describe Fastlane do
  describe Fastlane::FastFile do
    describe "Mercurial Commit Version Bump Action" do
      it "passes when modified files are a subset of expected changed files" do
        dirty_files = "file1,file2"
        expected_files = "file1,file2"

        result = Fastlane::FastFile.new.parse("lane :test do
          hg_commit_version_bump ({
            test_dirty_files: '#{dirty_files}',
            test_expected_files: '#{expected_files}',
          })
        end").runner.execute(:test)

        expect(result).to eq("hg commit -m 'Version Bump'")
      end

      it "passes when modified files are not a subset of expected files, but :force is true" do
        dirty_files = "file1,file3,file5"
        expected_files = "file1"

        result = Fastlane::FastFile.new.parse("lane :test do
          hg_commit_version_bump ({
            test_dirty_files: '#{dirty_files}',
            test_expected_files: '#{expected_files}',
            force: true
          })
        end").runner.execute(:test)

        expect(result).to eq("hg commit -m 'Version Bump'")
      end

      it "works with a custom commit message" do
        message = "custom message"

        result = Fastlane::FastFile.new.parse("lane :test do
          hg_commit_version_bump ({
            message: '#{message}',
          })
        end").runner.execute(:test)

        expect(result).to eq("hg commit -m '#{message}'")
      end

      it "raises an exception with no files changed" do
        dirty_files = ""
        expected_files = "file1"

        expect do
          Fastlane::FastFile.new.parse("lane :test do
          hg_commit_version_bump ({
            test_dirty_files: '#{dirty_files}',
            test_expected_files: '#{expected_files}',
          })
        end").runner.execute(:test)
        end.to raise_exception('No file changes picked up. Make sure you run the `increment_build_number` action first.')
      end
    end
  end
end
