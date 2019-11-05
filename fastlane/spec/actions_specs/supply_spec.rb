describe Fastlane do
  describe Fastlane::FastFile do
    describe "supply" do
      let(:apk_path) { "app/my.apk" }
      let(:apk_paths) { ["app/my1.apk", "app/my2.apk"] }
      let(:wrong_apk_paths) { ['wrong.apk', 'nope.apk'] }
      let(:aab_path) { "app/bundle.aab" }
      let(:aab_paths_unique) { ["app/bundle1.aab"] }
      let(:aab_paths_multiple) { ["app/bundle1.aab", "app/bundle2.aab"] }

      before :each do
        allow(File).to receive(:exist?).and_call_original
        expect(Supply::Uploader).to receive_message_chain(:new, :perform_upload)
      end

      describe "single APK path handling" do
        before :each do
          allow(File).to receive(:exist?).with(apk_path).and_return(true)
        end

        it "uses a provided APK path" do
          Fastlane::FastFile.new.parse("lane :test do
            supply(apk: '#{apk_path}')
          end").runner.execute(:test)

          expect(Supply.config[:apk]).to eq(apk_path)
          expect(Supply.config[:apk_paths]).to be_nil
          expect(Supply.config[:aab]).to be_nil
        end

        it "uses the lane context APK path if no other APK info is present" do
          FastlaneSpec::Env.with_action_context_values(Fastlane::Actions::SharedValues::GRADLE_APK_OUTPUT_PATH => apk_path) do
            Fastlane::FastFile.new.parse("lane :test do
              supply
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to eq(apk_path)
          expect(Supply.config[:apk_paths]).to be_nil
          expect(Supply.config[:aab]).to be_nil
        end

        it "ignores the lane context APK path if the APK param is present" do
          FastlaneSpec::Env.with_action_context_values(Fastlane::Actions::SharedValues::GRADLE_APK_OUTPUT_PATH => 'app/wrong.apk') do
            Fastlane::FastFile.new.parse("lane :test do
              supply(apk: '#{apk_path}')
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to eq(apk_path)
          expect(Supply.config[:apk_paths]).to be_nil
          expect(Supply.config[:aab]).to be_nil
        end

        it "ignores the lane context APK paths if the APK param is present" do
          wrong_apk_paths.each do |path|
            allow(File).to receive(:exist?).with(path).and_return(true)
          end

          FastlaneSpec::Env.with_action_context_values(Fastlane::Actions::SharedValues::GRADLE_ALL_APK_OUTPUT_PATHS => wrong_apk_paths) do
            Fastlane::FastFile.new.parse("lane :test do
              supply(apk: '#{apk_path}')
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to eq(apk_path)
          expect(Supply.config[:apk_paths]).to be_nil
          expect(Supply.config[:aab]).to be_nil
        end
      end

      describe "multiple APK path handling" do
        before :each do
          apk_paths.each do |path|
            allow(File).to receive(:exist?).with(path).and_return(true)
          end
        end

        it "uses the provided APK paths" do
          Fastlane::FastFile.new.parse("lane :test do
            supply(apk_paths: #{apk_paths})
          end").runner.execute(:test)

          expect(Supply.config[:apk]).to be_nil
          expect(Supply.config[:apk_paths]).to eq(apk_paths)
          expect(Supply.config[:aab]).to be_nil
        end

        it "uses the lane context APK paths if no other APK info is present" do
          FastlaneSpec::Env.with_action_context_values(Fastlane::Actions::SharedValues::GRADLE_ALL_APK_OUTPUT_PATHS => apk_paths) do
            Fastlane::FastFile.new.parse("lane :test do
              supply
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to be_nil
          expect(Supply.config[:apk_paths]).to eq(apk_paths)
          expect(Supply.config[:aab]).to be_nil
        end

        it "ignores the lane context APK paths if the APK paths param is present" do
          FastlaneSpec::Env.with_action_context_values(Fastlane::Actions::SharedValues::GRADLE_ALL_APK_OUTPUT_PATHS => ['wrong.apk', 'nope.apk']) do
            Fastlane::FastFile.new.parse("lane :test do
              supply(apk_paths: #{apk_paths})
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to be_nil
          expect(Supply.config[:apk_paths]).to eq(apk_paths)
          expect(Supply.config[:aab]).to be_nil
        end

        it "ignores the lane context APK path if the APK paths param is present" do
          allow(File).to receive(:exist?).with('wrong.apk').and_return(true)

          FastlaneSpec::Env.with_action_context_values(Fastlane::Actions::SharedValues::GRADLE_APK_OUTPUT_PATH => 'wrong.apk') do
            Fastlane::FastFile.new.parse("lane :test do
              supply(apk_paths: #{apk_paths})
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to be_nil
          expect(Supply.config[:apk_paths]).to eq(apk_paths)
          expect(Supply.config[:aab]).to be_nil
        end
      end

      describe "single AAB path handling" do
        before :each do
          allow(File).to receive(:exist?).with(aab_path).and_return(true)
        end

        it "uses a provided AAB path" do
          Fastlane::FastFile.new.parse("lane :test do
            supply(aab: '#{aab_path}')
          end").runner.execute(:test)

          expect(Supply.config[:apk]).to be_nil
          expect(Supply.config[:apk_paths]).to be_nil
          expect(Supply.config[:aab]).to eq(aab_path)
        end

        it "uses the lane context AAB path if no other AAB info is present" do
          FastlaneSpec::Env.with_action_context_values(Fastlane::Actions::SharedValues::GRADLE_AAB_OUTPUT_PATH => aab_path) do
            Fastlane::FastFile.new.parse("lane :test do
              supply
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to be_nil
          expect(Supply.config[:apk_paths]).to be_nil
          expect(Supply.config[:aab]).to eq(aab_path)
        end

        it "ignores the lane context AAB path if the AAB param is present" do
          FastlaneSpec::Env.with_action_context_values(Fastlane::Actions::SharedValues::GRADLE_AAB_OUTPUT_PATH => 'app/wrong.aab') do
            Fastlane::FastFile.new.parse("lane :test do
              supply(aab: '#{aab_path}')
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to be_nil
          expect(Supply.config[:apk_paths]).to be_nil
          expect(Supply.config[:aab]).to eq(aab_path)
        end
      end

      describe "multiple AAB path handling" do
        before :each do
          allow(File).to receive(:exist?).with(aab_path).and_return(true)
          allow(File).to receive(:exist?).with(aab_paths_unique).and_return(true)
          aab_paths_multiple.each do |path|
            allow(File).to receive(:exist?).with(path).and_return(true)
          end
        end

        it "uses the lane context AAB paths if no other AAB info is present" do
          FastlaneSpec::Env.with_action_context_values(Fastlane::Actions::SharedValues::GRADLE_ALL_AAB_OUTPUT_PATHS => aab_paths_unique) do
            Fastlane::FastFile.new.parse("lane :test do
              supply
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to be_nil
          expect(Supply.config[:apk_paths]).to be_nil
          expect(Supply.config[:aab]).to eq(aab_paths_unique.first)
        end

        it "ignores the lane context AAB paths if the AAB path param is present" do
          FastlaneSpec::Env.with_action_context_values(Fastlane::Actions::SharedValues::GRADLE_ALL_AAB_OUTPUT_PATHS => aab_paths_unique) do
            Fastlane::FastFile.new.parse("lane :test do
              supply(aab: '#{aab_path}')
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to be_nil
          expect(Supply.config[:apk_paths]).to be_nil
          expect(Supply.config[:aab]).to eq(aab_path)
        end

        it "use the lane context AAB unique path if the AAB paths has multiple values" do
          FastlaneSpec::Env.with_action_context_values(
            Fastlane::Actions::SharedValues::GRADLE_ALL_AAB_OUTPUT_PATHS => aab_paths_multiple,
            Fastlane::Actions::SharedValues::GRADLE_AAB_OUTPUT_PATH => aab_path
          ) do
            Fastlane::FastFile.new.parse("lane :test do
              supply
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to be_nil
          expect(Supply.config[:apk_paths]).to be_nil
          expect(Supply.config[:aab]).to eq(aab_path)
        end

        it "use the lane context AAB paths firt value if both unique and multiple contexts are set" do
          FastlaneSpec::Env.with_action_context_values(
            Fastlane::Actions::SharedValues::GRADLE_ALL_AAB_OUTPUT_PATHS => aab_paths_unique,
            Fastlane::Actions::SharedValues::GRADLE_AAB_OUTPUT_PATH => aab_path
          ) do
            Fastlane::FastFile.new.parse("lane :test do
              supply
            end").runner.execute(:test)
          end

          expect(Supply.config[:apk]).to be_nil
          expect(Supply.config[:apk_paths]).to be_nil
          expect(Supply.config[:aab]).to eq(aab_paths_unique.first)
        end
      end
    end
  end
end
