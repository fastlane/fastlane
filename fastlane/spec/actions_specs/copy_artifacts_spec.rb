describe Fastlane do
  describe Fastlane::FastFile do
    describe "Copy Artifacts Integration" do
      before do
        # Reset directories
        FileUtils.rm_rf('/tmp/fastlane')
        FileUtils.rm_rf('/tmp/fastlane2')

        # Create base test directory
        FileUtils.mkdir_p('/tmp/fastlane')
      end

      it "Copies a file to target path" do
        FileUtils.touch('/tmp/fastlane/copy_artifacts')

        Fastlane::FastFile.new.parse("lane :test do
          copy_artifacts(artifacts: '/tmp/fastlane/copy_artifacts', target_path: '/tmp/fastlane2')
        end").runner.execute(:test)

        expect(File.exist?('/tmp/fastlane2/copy_artifacts')).to eq(true)
      end

      it "Copies a directory and subfiles to target path" do
        FileUtils.mkdir_p('/tmp/fastlane/dir')
        FileUtils.touch('/tmp/fastlane/dir/copy_artifacts')

        Fastlane::FastFile.new.parse("lane :test do
          copy_artifacts(artifacts: '/tmp/fastlane/*', target_path: '/tmp/fastlane2')
        end").runner.execute(:test)
        expect(Dir.exist?('/tmp/fastlane2/dir')).to eq(true)
        expect(File.exist?('/tmp/fastlane2/dir/copy_artifacts')).to eq(true)
      end

      it "Copies a file with a space" do
        FileUtils.touch('/tmp/fastlane/copy_artifacts\ with\ a\ space')

        Fastlane::FastFile.new.parse("lane :test do
          copy_artifacts(artifacts: '/tmp/fastlane/copy_artifacts with a space', target_path: '/tmp/fastlane2')
        end").runner.execute(:test)
        expect(File.exist?('/tmp/fastlane/copy_artifacts\ with\ a\ space')).to eq(true)
      end

      it "Copies a file with verbose" do
        FileUtils.touch('/tmp/fastlane/copy_artifacts')

        expect(UI).to receive(:verbose).once.ordered.with('Copying artifacts /tmp/fastlane/copy_artifacts to /tmp/fastlane2')
        expect(UI).to receive(:verbose).once.ordered.with('Keeping original files')

        with_verbose(true) do
          Fastlane::FastFile.new.parse("lane :test do
            copy_artifacts(artifacts: '/tmp/fastlane/copy_artifacts', target_path: '/tmp/fastlane2')
          end").runner.execute(:test)
        end

        expect(File.exist?('/tmp/fastlane/copy_artifacts')).to eq(true)
        expect(File.exist?('/tmp/fastlane2/copy_artifacts')).to eq(true)
      end

      it "Copies a file without keeping original and verbose" do
        FileUtils.touch('/tmp/fastlane/copy_artifacts')

        expect(UI).to receive(:verbose).once.ordered.with('Copying artifacts /tmp/fastlane/copy_artifacts to /tmp/fastlane2')
        expect(UI).to receive(:verbose).once.ordered.with('Not keeping original files')

        with_verbose(true) do
          Fastlane::FastFile.new.parse("lane :test do
            copy_artifacts(artifacts: '/tmp/fastlane/copy_artifacts', target_path: '/tmp/fastlane2', keep_original: false)
          end").runner.execute(:test)
        end

        expect(File.exist?('/tmp/fastlane2/copy_artifacts')).to eq(true)
        expect(File.exist?('/tmp/fastlane/copy_artifacts')).to eq(false)
      end

      it "Copies a file with file missing does not fail (no flag set)" do
        Fastlane::FastFile.new.parse("lane :test do
          copy_artifacts(artifacts: '/tmp/fastlane/not_going_to_be_there', target_path: '/tmp/fastlane2')
        end").runner.execute(:test)

        expect(File.exist?('/tmp/fastlane2/not_going_to_be_there')).to eq(false)
      end

      it "Copies a file with file missing fails (flag set)" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            copy_artifacts(artifacts: '/tmp/fastlane/not_going_to_be_there', target_path: '/tmp/fastlane2', fail_on_missing: true)
          end").runner.execute(:test)
        end.to raise_error("Not all files were present in copy artifacts. Missing /tmp/fastlane/not_going_to_be_there")

        expect(File.exist?('/tmp/fastlane2/not_going_to_be_there')).to eq(false)
      end
    end
  end
end
