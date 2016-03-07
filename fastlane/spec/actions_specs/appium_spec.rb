require 'appium_lib'

describe Fastlane do
  describe Fastlane::FastFile do
    before :each do
      allow_any_instance_of(Appium::Driver).to receive(:start_driver)
    end

    context 'no parameters were given' do
      it 'should raises an error' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appium()
          end").runner.execute(:test)
        end.to raise_error
      end
    end

    context 'no platform were given' do
      it 'should raises an error' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appium({
              app_path: 'appium/app/Target.app',
              spec_path: 'appium/spec'
            })
          end").runner.execute(:test)
        end.to raise_error
      end
    end

    context 'no app_path were given' do
      it 'should raises an error' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appium({
              platform: 'iOS',
              spec_path: 'appium/spec'
            })
          end").runner.execute(:test)
        end.to raise_error
      end
    end

    context 'no spec_path were given' do
      it 'should raises an error' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appium({
              platform: 'iOS',
              app_path: 'appium/app/Target.app',
            })
          end").runner.execute(:test)
        end.to raise_error
      end
    end

    context 'with valid parameters' do
      before do
        allow(Fastlane::Actions::AppiumAction).to receive(:invoke_appium_server)
        allow(Fastlane::Actions::AppiumAction).to receive(:wait_for_appium_server)
      end

      before :each do
        allow(RSpec::Core::Runner).to receive(:run).and_return(status_code)
      end

      context 'when spec failed' do
        let(:status_code) { 1 }

        it 'should raises an error' do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              appium({
                platform: 'iOS',
                app_path: 'appium/app/Target.app',
                spec_path: 'appium/spec'
              })
            end").runner.execute(:test)
          end.to raise_error("Failed to run Appium spec. status code: #{status_code}".red)
        end
      end

      context 'when spec succeeded' do
        let(:status_code) { 0 }

        it 'should not raises an error' do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              appium({
                platform: 'iOS',
                app_path: 'appium/app/Target.app',
                spec_path: 'appium/spec'
              })
            end").runner.execute(:test)
          end.not_to raise_error
        end
      end
    end

    context 'with invoke_appium_server' do
      context 'is false' do
        before :each do
          allow(RSpec::Core::Runner).to receive(:run).and_return(0)
        end

        it 'should not invoke and wait appium server' do
          expect(Fastlane::Actions::AppiumAction).not_to receive(:invoke_appium_server)
          expect(Fastlane::Actions::AppiumAction).not_to receive(:wait_for_appium_server)

          expect do
            Fastlane::FastFile.new.parse("lane :test do
              appium({
                platform: 'iOS',
                app_path: 'appium/app/Target.app',
                spec_path: 'appium/spec',
                invoke_appium_server: false
              })
            end").runner.execute(:test)
          end.not_to raise_error
        end
      end

      context 'is true' do
        before :each do
          allow(RSpec::Core::Runner).to receive(:run).and_return(0)
        end

        it 'should invoke and wait appium server' do
          expect(Fastlane::Actions::AppiumAction).to receive(:invoke_appium_server)
          expect(Fastlane::Actions::AppiumAction).to receive(:wait_for_appium_server)

          expect do
            Fastlane::FastFile.new.parse("lane :test do
              appium({
                platform: 'iOS',
                app_path: 'appium/app/Target.app',
                spec_path: 'appium/spec',
                invoke_appium_server: true
              })
            end").runner.execute(:test)
          end.not_to raise_error
        end
      end
    end
  end
end
