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
      end

      describe "when use action after `backup_file` action" do
        before do
          Fastlane::FastFile.new.parse("lane :test do
            backup_file path: '#{File.join(test_path, file_path)}'
          end").runner.execute(:test)
          File.write(File.join(test_path, file_path), file_content.reverse)
        end

        it "should be restore file" do
          Fastlane::FastFile.new.parse("lane :test do
            restore_file path: '#{File.join(test_path, file_path)}'
          end").runner.execute(:test)
          restored_file = File.open(File.join(test_path, file_path)).read

          expect(restored_file).to include(file_content)
          expect(File).not_to(exist(File.join(test_path, backup_path)))
        end
      end

      describe "when use action without `backup_file` action" do
        it "should raise error" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              restore_file path: '#{File.join(test_path, file_path)}'
            end").runner.execute(:test)
          end.to raise_error("Could not find file '#{File.join(test_path, backup_path)}'")
        end
      end

      after do
        File.delete(File.join(test_path, backup_path)) if File.exist?(File.join(test_path, backup_path))
        File.delete(File.join(test_path, file_path))
      end
    end
  end
end
