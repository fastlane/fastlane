describe Fastlane do
  describe Fastlane::FastFile do
    describe "Cocoapods Integration" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end

      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod install")
      end

      it "default use case with no bundle exec" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(use_bundle_exec: false)
        end").runner.execute(:test)

        expect(result).to eq("pod install")
      end

      it "adds no-clean to command if clean is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            clean: false
          )
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod install --no-clean")
      end

      it "adds no-integrate to command if integrate is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            integrate: false
          )
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod install --no-integrate")
      end

      it "adds repo-update to command if repo_update is set to true" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            repo_update: true
          )
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod install --repo-update")
      end

      it "adds silent to command if silent is set to true" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            silent: true
          )
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod install --silent")
      end

      it "adds verbose to command if verbose is set to true" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            verbose: true
          )
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod install --verbose")
      end

      it "adds no-ansi to command if ansi is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            ansi: false
          )
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod install --no-ansi")
      end

      it "changes directory if podfile is set to the Podfile path" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            podfile: 'Project/Podfile'
          )
        end").runner.execute(:test)

        expect(result).to eq("cd 'Project' && bundle exec pod install")
      end

      it "changes directory if podfile is set to a directory" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            podfile: 'Project'
          )
        end").runner.execute(:test)

        expect(result).to eq("cd 'Project' && bundle exec pod install")
      end

      it "adds error_callback to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            error_callback: lambda { |result| puts 'failure' }
          )
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod install")
      end

      it "error_callback is executed on failure" do
        error_callback = double('error_callback')

        allow(Fastlane::Actions).to receive(:sh_control_output) {
          expect(Fastlane::Actions).to have_received(:sh_control_output).with(kind_of(String),
                                                                              hash_including(error_callback: error_callback))
        }
      end

      it "retries with --repo-update on error if try_repo_update_on_error is true" do
        allow(Fastlane::Actions).to receive(:sh_control_output) { |command, params|
          if command == 'bundle exec pod install'
            error_callback = params[:error_callback]
            error_callback.call('error')
          end
        }

        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            try_repo_update_on_error: true
          )
        end").runner.execute(:test)

        expect(Fastlane::Actions).to have_received(:sh_control_output).with("bundle exec pod install", hash_including(print_command: true)).ordered
        expect(Fastlane::Actions).to have_received(:sh_control_output).with("bundle exec pod install --repo-update", hash_including(print_command: true)).ordered
      end

      it 'doesnt retry with --repo-update if there were no errors' do
        allow(Fastlane::Actions).to receive(:sh_control_output) {}

        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            try_repo_update_on_error: true
          )
        end").runner.execute(:test)

        expect(Fastlane::Actions).to have_received(:sh_control_output).with("bundle exec pod install", hash_including(print_command: true)).ordered
        expect(Fastlane::Actions).to_not(have_received(:sh_control_output).with("bundle exec pod install --repo-update", hash_including(print_command: true)).ordered)
      end

      it "calls error_callback if retry with --repo-update finished with error" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return('.')
        allow(Fastlane::Actions).to receive(:sh_control_output) { |_, params|
          error_callback = params[:error_callback]
          error_callback.call('error')
        }
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            cocoapods(
              try_repo_update_on_error: true,
              error_callback: lambda { |r| raise r }
            )
          end").runner.execute(:test)
        end.to raise_error('error')
      end
    end
  end
end
