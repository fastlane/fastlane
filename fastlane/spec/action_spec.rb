describe Fastlane do
  describe Fastlane::Action do
    describe "#action_name" do
      it "converts the :: format to a readable one" do
        expect(Fastlane::Actions::IpaAction.action_name).to eq('ipa')
        expect(Fastlane::Actions::IncrementBuildNumberAction.action_name).to eq('increment_build_number')
      end
    end

    describe "Easy access to the lane context" do
      it "redirects to the correct class and method" do
        Fastlane::Actions.lane_context[:something] = 1
        expect(Fastlane::Action.lane_context).to eq({ something: 1 })
      end
    end

    describe "can call alias action" do
      it "redirects to the correct class and method" do
        result = Fastlane::FastFile.new.parse("lane :test do
          println \"alias\"
        end").runner.execute(:test)
      end

      it "alias does not crash with no param" do
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions")
        expect(UI).to receive(:important).with("modified")
        result = Fastlane::FastFile.new.parse("lane :test do
          somealias
        end").runner.execute(:test)
      end

      it "alias can override option" do
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions")
        expect(UI).to receive(:important).with("modified")
        result = Fastlane::FastFile.new.parse("lane :test do
          somealias(example: \"alias\", example_two: 'alias2')
        end").runner.execute(:test)
      end

      it "alias can override option with single param" do
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions")
        expect(UI).to receive(:important).with("modified")
        result = Fastlane::FastFile.new.parse("lane :test do
          someshortalias('PARAM')
        end").runner.execute(:test)
      end

      it "alias can override option with no param" do
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions")
        expect(UI).to receive(:important).with("modified")
        result = Fastlane::FastFile.new.parse("lane :test do
          somealias_no_param('PARAM')
        end").runner.execute(:test)
      end

      it "alias does not crash - when 'alias_used' not defined" do
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions")
        expect(UI).to receive(:important).with("run")
        result = Fastlane::FastFile.new.parse("lane :test do
          alias_no_used_handler_sample_alias('PARAM')
        end").runner.execute(:test)
      end
    end

    describe "Call another action from an action" do
      it "allows the user to call it using `other_action.rocket`" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions")
        ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfileActionFromAction')
        Fastlane::Actions.executed_actions.clear

        response = {
          rocket: "🚀",
          pwd: Dir.pwd
        }
        expect(ff.runner.execute(:something, :ios)).to eq(response)
        expect(Fastlane::Actions.executed_actions.map { |a| a[:name] }).to eq(['from'])
      end

      it "shows only actions called from Fastfile" do
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions")
        ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfileActionFromActionWithOtherAction')
        Fastlane::Actions.executed_actions.clear

        ff.runner.execute(:something, :ios)
        expect(Fastlane::Actions.executed_actions.map { |a| a[:name] }).to eq(['from', 'example'])
      end

      it "shows an appropriate error message when trying to directly call an action" do
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions")
        ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfileActionFromActionInvalid')
        expect do
          ff.runner.execute(:something, :ios)
        end.to raise_error("To call another action from an action use `other_action.rocket` instead")
      end
    end

    describe "Action.sh" do
      it "delegates to Actions.sh_control_output" do
        mock_status = double(:status, exitstatus: 0)
        expect(Fastlane::Actions).to receive(:sh_control_output).with("ls", "-la").and_yield(mock_status, "Command output")
        Fastlane::Action.sh("ls", "-la") do |status, result|
          expect(status.exitstatus).to eq(0)
          expect(result).to eq("Command output")
        end
      end
    end
  end
end
