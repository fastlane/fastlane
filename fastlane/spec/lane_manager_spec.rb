describe Fastlane do
  describe Fastlane::LaneManager do
    describe "#init" do
      it "raises an error on invalid platform" do
        expect do
          Fastlane::LaneManager.cruise_lane(123, nil)
        end.to raise_error("platform must be a string")
      end
      it "raises an error on invalid lane" do
        expect do
          Fastlane::LaneManager.cruise_lane(nil, 123)
        end.to raise_error("lane must be a string")
      end

      describe "dotenv" do
        it "Finds the dotenv in the parent" do
          ensure_dot_env_value_from_fastlane_or_parent('withFastfiles/parentonly', nil, { DOTENV: 'parent' })
          ensure_dot_env_value_from_parent_only('withoutFastfiles/parentonly', nil, { DOTENV: 'parent' })
        end

        it "Finds the dotenv in the fastlane dir" do
          ensure_dot_env_value_from_fastlane_or_parent('withFastfiles/fastlaneonly', nil, { DOTENV: 'fastlane' })
          ensure_dot_env_value_from_parent_only('withoutFastfiles/fastlaneonly', nil, { DOTENV: 'fastlane' })
        end

        it "Finds the dotenv in the fastlane dir when in both parent and fastlane" do
          ensure_dot_env_value_from_fastlane_or_parent('withFastfiles/parentandfastlane', nil, { DOTENV: 'fastlane' })
          ensure_dot_env_value_from_parent_only('withoutFastfiles/parentandfastlane', nil, { DOTENV: 'fastlane' })
        end

        it "Doesn't find dotenv when not running in a parent of fastlane folder" do
          ensure_dot_env_value_from_parent_only('elsewhere', nil, { DOTENV: nil })
        end

        it "Supports multiple envs, and loads them in the specified order" do
          ensure_dot_env_value_from_fastlane_or_parent('multiple', "one,two", { DOTENV1: 'two', DOTENV2: 'two' })
        end

        # this method ensures that the .env file contains the expected value
        # when reading it from either fastlane or its parent
        # the fastlane folders should contain a Fastfile
        def ensure_dot_env_value_from_fastlane_or_parent(parent_dir, envs, expected_values)
          project_dir = File.absolute_path('./fastlane/spec/fixtures/dotenvs/' + parent_dir)
          fastlane_dir = File.absolute_path(project_dir + '/fastlane')
          ensure_dot_env_value_from_folders([project_dir, fastlane_dir], envs, expected_values)
        end

        # this method ensures that the .env file contains the expected value
        # when reading it from fastlane's parent only.
        # the fastlane folders shouldn't contain a Fastfile
        def ensure_dot_env_value_from_parent_only(parent_dir, envs, expected_values)
          project_dir = File.absolute_path('./fastlane/spec/fixtures/dotenvs/' + parent_dir)
          ensure_dot_env_value_from_folders([project_dir], envs, expected_values)
        end

        def ensure_dot_env_value_from_folders(folders, envs, expected_values)
          folders.each do |dir|
            expected_values.each do |k, v|
              ENV.delete(k.to_s)
            end
            Dir.chdir(dir) do
              ff = Fastlane::LaneManager.load_dot_env(envs)
              expected_values.each do |k, v|
                expect(ENV[k.to_s]).to eq(v)
              end
            end
          end
        end
      end

      describe "successful init" do
        before do
          allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
        end

        it "Successfully handles exceptions" do
          expect do
            ff = Fastlane::LaneManager.cruise_lane('ios', 'crashy')
          end.to raise_error('my exception')
        end

        it "Uses the default platform if given" do
          ff = Fastlane::LaneManager.cruise_lane(nil, 'empty') # look, without `ios`
          lanes = ff.runner.lanes
          expect(lanes[nil][:test].description).to eq([])
          expect(lanes[:ios][:crashy].description).to eq(["This action does nothing", "but crash"])
          expect(lanes[:ios][:empty].description).to eq([])
        end

        it "supports running a lane without a platform even when there is a default_platform" do
          path = "/tmp/fastlane/tests.txt"
          File.delete(path) if File.exist?(path)
          expect(File.exist?(path)).to eq(false)

          ff = Fastlane::LaneManager.cruise_lane(nil, 'test')

          expect(File.exist?(path)).to eq(true)
          expect(ff.runner.current_lane).to eq(:test)
          expect(ff.runner.current_platform).to eq(nil)
        end
      end
    end
  end
end
