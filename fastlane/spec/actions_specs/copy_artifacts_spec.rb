describe Fastlane do
  describe Fastlane::FastFile do
    describe "Copy Artifacts Integration" do
      before do
        # Create base test directory
        @tmp_path = Dir.mktmpdir
        FileUtils.mkdir_p("#{@tmp_path}/source")
      end

      it "Copies a file to target path" do
        FileUtils.touch("#{@tmp_path}/source/copy_artifacts")

        Fastlane::FastFile.new.parse("lane :test do
          copy_artifacts(artifacts: '#{@tmp_path}/source/copy_artifacts', target_path: '#{@tmp_path}/target')
        end").runner.execute(:test)

        expect(File.exist?("#{@tmp_path}/target/copy_artifacts")).to eq(true)
      end

      it "Copies a directory and subfiles to target path" do
        FileUtils.mkdir_p("#{@tmp_path}/source/dir")
        FileUtils.touch("#{@tmp_path}/source/dir/copy_artifacts")

        Fastlane::FastFile.new.parse("lane :test do
          copy_artifacts(artifacts: '#{@tmp_path}/source/*', target_path: '#{@tmp_path}/target/')
        end").runner.execute(:test)

        expect(Dir.exist?("#{@tmp_path}/target/dir")).to eq(true)
        expect(File.exist?("#{@tmp_path}/target/dir/copy_artifacts")).to eq(true)
      end

      it "Copies a file with a space" do
        FileUtils.touch("#{@tmp_path}/source/copy_artifacts\ with\ a\ space")

        Fastlane::FastFile.new.parse("lane :test do
          copy_artifacts(artifacts: '#{@tmp_path}/source/copy_artifacts\ with\ a\ space', target_path: '#{@tmp_path}/target')
        end").runner.execute(:test)

        expect(File.exist?("#{@tmp_path}/target/copy_artifacts\ with\ a\ space")).to eq(true)
      end

      it "Copies a file with verbose" do
        source_path = "#{@tmp_path}/source"
        FileUtils.touch(source_path)
        target_path = "#{@tmp_path}/target738"

        expect(UI).to receive(:verbose).once.ordered.with("Copying artifacts #{source_path} to #{target_path}")
        expect(UI).to receive(:verbose).once.ordered.with('Keeping original files')

        FastlaneSpec::Env.with_verbose(true) do
          Fastlane::FastFile.new.parse("lane :test do
            copy_artifacts(artifacts: '#{source_path}', target_path: '#{target_path}')
          end").runner.execute(:test)
        end

        expect(File.exist?(source_path)).to eq(true)
        expect(File.exist?(target_path)).to eq(true)
      end

      it "Copies a file without keeping original and verbose" do
        source_path = "#{@tmp_path}/source"
        FileUtils.touch(source_path)
        target_path = "#{@tmp_path}/target987"

        expect(UI).to receive(:verbose).once.ordered.with("Copying artifacts #{source_path} to #{target_path}")
        expect(UI).to receive(:verbose).once.ordered.with('Not keeping original files')

        FastlaneSpec::Env.with_verbose(true) do
          Fastlane::FastFile.new.parse("lane :test do
            copy_artifacts(artifacts: '#{source_path}', target_path: '#{target_path}', keep_original: false)
          end").runner.execute(:test)
        end

        expect(File.exist?(source_path)).to eq(false)
        expect(File.exist?(target_path)).to eq(true)
      end

      it "Copies a file with file missing does not fail (no flag set)" do
        source_path = "#{@tmp_path}/source/missing"
        target_path = "#{@tmp_path}/target123"

        Fastlane::FastFile.new.parse("lane :test do
          copy_artifacts(artifacts: '#{source_path}', target_path: '#{target_path}')
        end").runner.execute(:test)

        expect(File.exist?(source_path)).to eq(false)
      end

      it "Copies a file with file missing fails (flag set)" do
        source_path = "#{@tmp_path}/source/not_going_to_be_there"
        target_path = "#{@tmp_path}/target456"

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            copy_artifacts(artifacts: '#{source_path}', target_path: '#{target_path}', fail_on_missing: true)
          end").runner.execute(:test)
        end.to raise_error("Not all files were present in copy artifacts. Missing #{source_path}")

        expect(File.exist?(source_path)).to eq(false)
      end
    end
  end
end
