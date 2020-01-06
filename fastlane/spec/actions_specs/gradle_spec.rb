describe Fastlane do
  describe Fastlane::FastFile do
    describe "gradle" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end

      describe "output controls" do
        let(:expected_command) { "#{File.expand_path('README.md').shellescape} tasks -p ." }

        it "prints the command and the command's output by default" do
          expect(Fastlane::Actions).to receive(:sh_control_output).with(expected_command, print_command: true, print_command_output: true).and_call_original

          Fastlane::FastFile.new.parse("lane :build do
            gradle(
              task: 'tasks',
              gradle_path: './README.md'
            )
          end").runner.execute(:build)
        end

        it "suppresses the command text and prints the command's output" do
          expect(Fastlane::Actions).to receive(:sh_control_output).with(expected_command, print_command: false, print_command_output: true).and_call_original

          Fastlane::FastFile.new.parse("lane :build do
            gradle(
              task: 'tasks',
              gradle_path: './README.md',
              print_command: false
            )
          end").runner.execute(:build)
        end

        it "prints the command text and suppresses the command's output" do
          expect(Fastlane::Actions).to receive(:sh_control_output).with(expected_command, print_command: true, print_command_output: false).and_call_original

          Fastlane::FastFile.new.parse("lane :build do
            gradle(
              task: 'tasks',
              gradle_path: './README.md',
              print_command_output: false
            )
          end").runner.execute(:build)
        end

        it "suppresses the command text and suppresses the command's output" do
          expect(Fastlane::Actions).to receive(:sh_control_output).with(expected_command, print_command: false, print_command_output: false).and_call_original

          Fastlane::FastFile.new.parse("lane :build do
            gradle(
              task: 'tasks',
              gradle_path: './README.md',
              print_command: false,
              print_command_output: false
            )
          end").runner.execute(:build)
        end
      end

      it "generates a valid command" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assemble', flavor: 'WorldDomination', build_type: 'Release', properties: { 'versionCode' => 200}, gradle_path: './README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md').shellescape} assembleWorldDominationRelease -p . -PversionCode=200")
      end

      it "correctly escapes the gradle path" do
        tmp_path = Dir.mktmpdir
        gradle_path = "#{tmp_path}/fake gradle/path" # this value is interesting because it contains a space in the path
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(gradle_path).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(
            task: 'assemble',
            flavor: 'WorldDomination',
            build_type: 'Release',
            properties: {'versionCode' => 200},
            serial: 'abc123',
            gradle_path: '#{gradle_path}'
          )
        end").runner.execute(:build)

        expect(result).to eq("ANDROID_SERIAL=abc123 #{gradle_path.shellescape} assembleWorldDominationRelease -p . -PversionCode=200")
      end

      it "correctly escapes multiple properties and types" do
        notes_key = 'Release Notes' # this value is interesting because it contains a space in the key
        notes_result = 'World Domination Achieved!' # this value is interesting because it contains multiple spaces
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assemble', flavor: 'WorldDomination', build_type: 'Release', properties: { 'versionCode' => 200, '#{notes_key}' => '#{notes_result}'}, system_properties: { 'org.gradle.daemon' => 'true' } , gradle_path: './README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md').shellescape} assembleWorldDominationRelease -p . -PversionCode=200 -P#{notes_key.shellescape}=#{notes_result.shellescape} -Dorg.gradle.daemon=true")
      end

      it "correctly uses the serial" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assemble', flavor: 'WorldDomination', build_type: 'Release', properties: { 'versionCode' => 200}, serial: 'abc123', gradle_path: './README.md')
        end").runner.execute(:build)

        expect(result).to eq("ANDROID_SERIAL=abc123 #{File.expand_path('README.md').shellescape} assembleWorldDominationRelease -p . -PversionCode=200")
      end

      it "supports multiple flavors" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assemble', build_type: 'Release', gradle_path: './README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md').shellescape} assembleRelease -p .")
      end

      it "supports multiple build types" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assemble', flavor: 'WorldDomination', gradle_path: './README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md').shellescape} assembleWorldDomination -p .")
      end

      it "supports multiple flavors and build types" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assemble', gradle_path: './README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md').shellescape} assemble -p .")
      end

      it "supports the backwards compatible syntax" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assembleWorldDominationRelease', gradle_path: './README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md').shellescape} assembleWorldDominationRelease -p .")
      end

      it "supports multiple tasks" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(tasks: ['assembleDebug', 'bundleDebug'], gradle_path: './README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md').shellescape} assembleDebug bundleDebug -p .")
      end

      it "a task or tasks are required" do
        expect do
          result = Fastlane::FastFile.new.parse("lane :build do
            gradle(gradle_path: './README.md')
          end").runner.execute(:build)
        end.to(
          raise_error(FastlaneCore::Interface::FastlaneError) do |error|
            expect(error.message).to match('Please pass a gradle task or tasks')
          end
        )
      end

      describe "the step name displayed in fastlane summary" do
        it "a gradle task name is displayed" do
          task_name = 'assembleWorldDominationRelease'

          Fastlane::FastFile.new.parse("lane :build do
            gradle(task: '#{task_name}', gradle_path: './README.md')
          end").runner.execute(:build)

          last_action = Fastlane::Actions.executed_actions.last
          expect(last_action[:name]).to eq(task_name)
        end

        it "a gradle tasks name is displayed" do
          task_name_1 = 'assembleWorldDominationRelease'
          task_name_2 = 'assemblePlanB'

          task_name = "#{task_name_1} #{task_name_2}"

          Fastlane::FastFile.new.parse("lane :build do
            gradle(tasks: ['#{task_name_1}', '#{task_name_2}'], gradle_path: './README.md')
          end").runner.execute(:build)

          last_action = Fastlane::Actions.executed_actions.last
          expect(last_action[:name]).to eq(task_name)
        end
      end
    end
  end
end
