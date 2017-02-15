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
        end.to raise_error("To call another action from an action use `OtherAction.rocket` instead")
      end
    end

    describe "shell_out_should_use_bundle_exec?" do
      it "should be false when using contained version" do
        expect(FastlaneCore::Helper).to receive(:contained_fastlane?).and_return(true)
        expect(Fastlane::Action.shell_out_should_use_bundle_exec?).to eq(false)
      end

      it "should return true if a Gemfile was provided by the parent process" do
        with_env_values('BUNDLE_GEMFILE' => 'someGemfile') do
          expect(Fastlane::Action.shell_out_should_use_bundle_exec?).to eq(true)
        end
      end

      it "should return true if file named 'Gemfile' is found in the current directory" do
        with_env_values('BUNDLE_GEMFILE' => nil) do
          allow(Pathname).to receive(:pwd).and_return("./fastlane/spec/fixtures/gemfiles/a")
          expect(Fastlane::Action.shell_out_should_use_bundle_exec?).to eq(true)
        end
      end

      it "should return true if file named 'gems.rb' is found in the current directory" do
        with_env_values('BUNDLE_GEMFILE' => nil) do
          allow(Pathname).to receive(:pwd).and_return("./fastlane/spec/fixtures/gemfiles/b")
          expect(Fastlane::Action.shell_out_should_use_bundle_exec?).to eq(true)
        end
      end

      it "should return true if file named 'Gemfile' is found in some ancestor directory" do
        with_env_values('BUNDLE_GEMFILE' => nil) do
          allow(Pathname).to receive(:pwd).and_return("./fastlane/spec/fixtures/gemfiles/a/aa")
          expect(Fastlane::Action.shell_out_should_use_bundle_exec?).to eq(true)
        end
      end

      it "should return true if file named 'gems.rb' is found in some ancestor directory" do
        with_env_values('BUNDLE_GEMFILE' => nil) do
          allow(Pathname).to receive(:pwd).and_return("./fastlane/spec/fixtures/gemfiles/b/bb")
          expect(Fastlane::Action.shell_out_should_use_bundle_exec?).to eq(true)
        end
      end

      it "should return false if no Gemfile can be found" do
        with_env_values('BUNDLE_GEMFILE' => nil) do
          allow(File).to receive(:file?).and_return(false)
          expect(Fastlane::Action.shell_out_should_use_bundle_exec?).to eq(false)
        end
      end
    end
  end
end
