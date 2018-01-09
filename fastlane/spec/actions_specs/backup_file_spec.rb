describe Fastlane do
  describe Fastlane::FastFile do
    describe "Backup file Integration" do
      let(:test_path) { "/tmp/fastlane/tests/fastlane" }
      let(:file_path) { "file.txt" }
      let(:backup_path) { "#{file_path}.back" }
      let(:file_content) { Time.now.to_s }

      before do
        FileUtils.mkdir_p(test_path)
        File.write(File.join(test_path, file_path), file_content)

        Fastlane::FastFile.new.parse("lane :test do
          backup_file path: '#{File.join(test_path, file_path)}'
        end").runner.execute(:test)
      end

      it "backup file to `.back` file" do
        expect(
          File.open(File.join(test_path, backup_path))
        ).to include(file_content)
      end

      after do
        File.delete(File.join(test_path, file_path))
        File.delete(File.join(test_path, backup_path))
      end
    end
  end
end
