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
          ensure_dot_env_value_from_fastlane_or_parent('withFastfiles/parentonly', 'parent')
          ensure_dot_env_value_from_parent_only('withoutFastfiles/parentonly', 'parent')
        end

        it "Finds the dotenv in the fastlane dir" do
          ensure_dot_env_value_from_fastlane_or_parent('withFastfiles/fastlaneonly', 'fastlane')
          ensure_dot_env_value_from_parent_only('withoutFastfiles/fastlaneonly', 'fastlane')
        end

        it "Finds the dotenv in the fastlane dir when in both parent and fastlane" do
          ensure_dot_env_value_from_fastlane_or_parent('withFastfiles/parentandfastlane', 'fastlane')
          ensure_dot_env_value_from_parent_only('withoutFastfiles/parentandfastlane', 'fastlane')
        end

        it "Doesn't find dotenv when not running in a parent of fastlane folder" do
          ensure_dot_env_value_from_parent_only('elsewhere', nil)
        end

        # this method ensures that the .env file contains the expected value
        # when reading it from either fastlane or its parent
        # the fastlane folders should contain a Fastfile
        def ensure_dot_env_value_from_fastlane_or_parent(parent_dir, expected_value)
          project_dir = File.absolute_path('./fastlane/spec/fixtures/dotenvs/' + parent_dir)
          fastlane_dir = File.absolute_path(project_dir + '/fastlane')
          # current limitation in FastlaneFolder.
          allow(FastlaneCore::Helper).to receive(:is_test?).and_return(false)
          [project_dir, fastlane_dir].each do |dir|
            ENV.delete('DOTENV')
            Dir.chdir(dir) do
              ff = Fastlane::LaneManager.load_dot_env(nil)
              expect(ENV['DOTENV']).to eq(expected_value)
            end
          end
        end

        # this method ensures that the .env file contains the expected value
        # when reading it from fastlane's parent only.
        # the fastlane folders shouldn't contain a Fastfile
        def ensure_dot_env_value_from_parent_only(parent_dir, expected_value)
          project_dir = File.absolute_path('./fastlane/spec/fixtures/dotenvs/' + parent_dir)
          # current limitation in FastlaneFolder.
          allow(FastlaneCore::Helper).to receive(:is_test?).and_return(false)
          [project_dir].each do |dir|
            ENV.delete('DOTENV')
            Dir.chdir(dir) do
              ff = Fastlane::LaneManager.load_dot_env(nil)
              expect(ENV['DOTENV']).to eq(expected_value)
            end
          end
        end
      end

      describe "successfull init" do
        before do
          allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./fastlane/spec/fixtures/fastfiles/'))
        end

        it "Successfully collected all actions" do
          ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
          expect(ff.collector.launches).to eq({ default_platform: 1, frameit: 1, team_id: 2 })
        end

        it "Successfully handles exceptions" do
          expect do
            ff = Fastlane::LaneManager.cruise_lane('ios', 'crashy')
          end.to raise_error 'my exception'
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
