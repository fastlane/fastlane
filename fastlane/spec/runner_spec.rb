describe Fastlane do
  describe Fastlane::Runner do
    describe "#available_lanes" do
      before do
        @ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfileGrouped')
      end

      it "lists all available lanes" do
        expect(@ff.runner.available_lanes).to eq(["test", "anotherroot", "mac beta", "ios beta", "ios release", "android beta", "android witherror", "android unsupported_action"])
      end

      it "allows filtering of results" do
        expect(@ff.runner.available_lanes('android')).to eq(["android beta", "android witherror", "android unsupported_action"])
      end

      it "returns an empty array if invalid input is given" do
        expect(@ff.runner.available_lanes('asdfasdfasdf')).to eq([])
      end

      it "doesn't show private lanes" do
        expect(@ff.runner.available_lanes).to_not(include('android such_private'))
      end
    end

    describe "#verify_compatible_os" do
      before do
        @ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfileGrouped')
        @action = 'scan' # TODO Somehow mock action instead of reusing scan
        @class_ref, arguments_unused = @ff.runner.get_class_ref(@action)
        puts 'class_ref = '+ @class_ref.to_s
      end

      it "does not raise an expcetion for action scan on OS macOS" do
        allow(FastlaneCore::Helper).to receive(:operating_system).and_return('macOS')
        expect do
          @ff.runner.verify_compatible_os(@action, @class_ref)
        end.not_to raise_error
      end

      it "does raise an exception for action scan on OS Windows " do
        allow(FastlaneCore::Helper).to receive(:operating_system).and_return('Windows')
        expect do
          @ff.runner.verify_compatible_os(@action, @class_ref)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end
     
      it "does raise an exception for action scan on OS Linux" do
        allow(FastlaneCore::Helper).to receive(:operating_system).and_return('Linux')
        expect do
          @ff.runner.verify_compatible_os(@action, @class_ref)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end

      it "does not raise an exception but output a message for action scan on OS Windows " do
        allow(FastlaneCore::Helper).to receive(:operating_system).and_return('Windows')
        with_env_values('FASTLANE_IGNORE_OS_INCOMPAT' => 1) do
          expectiation = expect do
            @ff.runner.verify_compatible_os(@action, @class_ref)
          end.not_to raise_error
          expectiation.to output("Continuing anyway").to_stdout
        end
      end
     
      it "does not raise an exception but output a message for action scan on OS Linux" do
        allow(FastlaneCore::Helper).to receive(:operating_system).and_return('Linux')
        with_env_values('FASTLANE_IGNORE_OS_INCOMPAT' => 1) do
          expectiation = expect do
            @ff.runner.verify_compatible_os(@action, @class_ref)
          end.not_to raise_error
          expectiation.to output("Continuing anyway").to_stdout
        end
      end
    end
  end
end
