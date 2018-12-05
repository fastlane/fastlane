class FeatureHelper
  def self.disabled_class_method
  end

  def self.enabled_class_method
  end

  def disabled_instance_method; end

  def enabled_instance_method; end

  def self.reset_test_method
    FeatureHelper.instance_eval { undef test_method }
  end

  def reset_test_method
    undef test_method
  end
end

describe FastlaneCore do
  describe FastlaneCore::Feature do
    describe "Register a Feature" do
      it "registers a feature successfully with environment variable and description" do
        expect do
          FastlaneCore::Feature.register(env_var: "TEST_ENV_VAR_VALID", description: "A valid test feature")
        end.not_to(raise_error)
      end

      it "raises an error if no environment variable specified" do
        expect do
          FastlaneCore::Feature.register(description: "An invalid test feature")
        end.to raise_error("Invalid Feature")
      end

      it "raises an error if no description specified" do
        expect do
          FastlaneCore::Feature.register(env_var: "TEST_ENV_VAR_INVALID_NO_DESCRIPTION")
        end.to raise_error("Invalid Feature")
      end
    end

    describe '#enabled?' do
      before(:all) do
        FastlaneCore::Feature.register(env_var: 'TEST_ENV_VAR_FOR_ENABLED_TESTS', description: 'Test feature for enabled? tests')
      end

      it "reports unregistered features as not enabled" do
        expect(FastlaneCore::Feature.enabled?('TEST_ENV_VAR_NOT_REGISTERED')).to be_falsey
      end

      it "reports undefined features as not enabled, even if the environment variable is set" do
        with_env_values('TEST_ENV_VAR_NOT_REGISTERED' => '1') do
          expect(FastlaneCore::Feature.enabled?('TEST_ENV_VAR_NOT_REGISTERED')).to be_falsey
        end
      end

      it "reports features for missing environment variables as disabled" do
        expect(FastlaneCore::Feature.enabled?('TEST_ENV_VAR_FOR_ENABLED_TESTS')).to be_falsey
      end

      it "reports features for disabled environment variables as disabled" do
        with_env_values('TEST_ENV_VAR_FOR_ENABLED_TESTS' => '0') do
          expect(FastlaneCore::Feature.enabled?('TEST_ENV_VAR_FOR_ENABLED_TESTS')).to be_falsey
        end
      end

      it "reports features for environment variables as enabled" do
        with_env_values('TEST_ENV_VAR_FOR_ENABLED_TESTS' => '1') do
          expect(FastlaneCore::Feature.enabled?('TEST_ENV_VAR_FOR_ENABLED_TESTS')).to be_truthy
        end
      end
    end

    describe "Register feature methods" do
      before(:all) do
        FastlaneCore::Feature.register(env_var: 'TEST_ENV_VAR_FOR_METHOD_TESTS', description: 'Test feature for feature method registration tests')
      end

      it "Calls disabled class method with disabled environment variable" do
        with_env_values('TEST_ENV_VAR_FOR_METHOD_TESTS' => '0') do
          FastlaneCore::Feature.register_class_method(klass: FeatureHelper,
                                                     symbol: :test_method,
                                            disabled_symbol: :disabled_class_method,
                                             enabled_symbol: :enabled_class_method,
                                                    env_var: 'TEST_ENV_VAR_FOR_METHOD_TESTS')

          expect(FeatureHelper).to receive(:disabled_class_method)
          FeatureHelper.test_method
          FeatureHelper.reset_test_method
        end
      end

      it "Calls enabled class method with enabled environment variable" do
        with_env_values('TEST_ENV_VAR_FOR_METHOD_TESTS' => '1') do
          FastlaneCore::Feature.register_class_method(klass: FeatureHelper,
                                                     symbol: :test_method,
                                            disabled_symbol: :disabled_class_method,
                                             enabled_symbol: :enabled_class_method,
                                                    env_var: 'TEST_ENV_VAR_FOR_METHOD_TESTS')

          expect(FeatureHelper).to receive(:enabled_class_method)
          FeatureHelper.test_method
          FeatureHelper.reset_test_method
        end
      end

      it "Calls disabled instance method with disabled environment variable" do
        with_env_values('TEST_ENV_VAR_FOR_METHOD_TESTS' => '0') do
          instance = FeatureHelper.new
          FastlaneCore::Feature.register_instance_method(klass: FeatureHelper,
                                                        symbol: :test_method,
                                               disabled_symbol: :disabled_instance_method,
                                                enabled_symbol: :enabled_instance_method,
                                                       env_var: 'TEST_ENV_VAR_FOR_METHOD_TESTS')

          expect(instance).to receive(:disabled_instance_method)
          instance.test_method
          instance.reset_test_method
        end
      end

      it "Calls enabled instance method with enabled environment variable" do
        with_env_values('TEST_ENV_VAR_FOR_METHOD_TESTS' => '1') do
          instance = FeatureHelper.new
          FastlaneCore::Feature.register_instance_method(klass: FeatureHelper,
                                                        symbol: :test_method,
                                               disabled_symbol: :disabled_instance_method,
                                                enabled_symbol: :enabled_instance_method,
                                                       env_var: 'TEST_ENV_VAR_FOR_METHOD_TESTS')

          expect(instance).to receive(:enabled_instance_method)
          instance.test_method
          instance.reset_test_method
        end
      end
    end
  end
end
