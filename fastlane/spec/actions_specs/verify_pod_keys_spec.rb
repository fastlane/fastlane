describe Fastlane do
  describe Fastlane::FastFile do
    describe "CocoaPods Keys Verification" do
      let(:key) { "Key" }
      let(:target) { "Target" }

      before(:each) do
        options = { "target" => :target, "keys" => [:key] }
        allow(Fastlane::Actions::VerifyPodKeysAction).to receive(:plugin_options).and_return(options)
      end

      describe "valid values" do
        value = "Value"

        before(:each) do
          allow(Fastlane::Actions::VerifyPodKeysAction).to receive(:value).with(:key, :target).and_return(value)
        end

        it "raises no exception" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_pod_keys
            end").runner.execute(:test)
          end.to_not(raise_error)
        end
      end

      describe "the pod keys command" do
        def command_for(key, target)
          command = nil
          allow(Fastlane::Actions::VerifyPodKeysAction).to receive(:`) do |cmd|
            command = cmd
            "[cocoapods-keys] secret"
          end
          Fastlane::Actions::VerifyPodKeysAction.value(key, target)
          Shellwords.split(command)
        end

        it "passes a target name with a space as one argument" do
          expect(command_for("MyKey", "My App")).to eq(["pod", "keys", "get", "MyKey", "My App"])
        end

        it "passes no target argument when no target is set" do
          expect(command_for("MyKey", "")).to eq(["pod", "keys", "get", "MyKey"])
        end
      end

      describe "invalid values" do
        value = ""

        before(:each) do
          allow(Fastlane::Actions::VerifyPodKeysAction).to receive(:value).with(:key, :target).and_return(value)
        end

        it "raises an exception" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_pod_keys
            end").runner.execute(:test)
          end.to raise_error("Did not pass validation for key key. Run `[bundle exec] pod keys get key target` to see what it is. It's likely this is running with empty/OSS keys.")
        end
      end
    end
  end
end
