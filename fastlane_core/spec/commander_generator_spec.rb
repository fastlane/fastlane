describe FastlaneCore do
  describe FastlaneCore::CommanderGenerator do
    describe 'while options parsing' do
      describe '' do
        it 'should not return `true` for String options with no short flag' do
          config_items = [
            FastlaneCore::ConfigItem.new(key: :long_option_only_string,
                                         description: "desc",
                                         is_string: true,
                                         default_value: "blah",
                                         optional: true),
            FastlaneCore::ConfigItem.new(key: :bool,
                                         description: "desc",
                                         default_value: false,
                                         is_string: false)
          ]

          stub_commander_runner_args(['--long_option_only_string', 'value', '--bool', 'false'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:long_option_only_string]).to eq('value')
          expect(program.options[:bool]).to eq('false')
        end
      end

      describe 'pass-through arguments' do
        it 'captures those that are not command names or flags' do
          # 'test' is the command name set up by TestCommanderProgram
          stub_commander_runner_args(['test', 'other', '-b'])

          program = TestCommanderProgram.run([
                                               FastlaneCore::ConfigItem.new(key: :boolean_1,
                                                                            short_option: '-b',
                                                                            description: 'Boolean 1',
                                                                            is_string: false)
                                             ])

          expect(program.args).to eq(['other'])
        end
      end

      describe 'String flags' do
        let(:config_items) do
          [
            FastlaneCore::ConfigItem.new(key: :string_1,
                                         short_option: '-s',
                                         description: 'String 1',
                                         is_string: true)
          ]
        end

        it 'raises MissingArgument for short flags with missing values' do
          stub_commander_runner_args(['-s'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'raises MissingArgument for long flags with missing values' do
          stub_commander_runner_args(['--string_1'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'captures the provided value for short flags' do
          stub_commander_runner_args(['-s', 'value'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:string_1]).to eq('value')
        end

        it 'captures the provided value for long flags' do
          stub_commander_runner_args(['--string_1', 'value'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:string_1]).to eq('value')
        end
      end

      describe ':shell_string flags' do
        let(:config_items) do
          [
            FastlaneCore::ConfigItem.new(key: :shell_string_1,
                                         short_option: '-s',
                                         description: 'Shell String 1',
                                         type: :shell_string)
          ]
        end

        it 'raises MissingArgument for short flags with missing values' do
          stub_commander_runner_args(['-s'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'raises MissingArgument for long flags with missing values' do
          stub_commander_runner_args(['--shell_string_1'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'captures the provided value for short flags' do
          stub_commander_runner_args(['-s', 'foo bar=baz qux'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:shell_string_1]).to eq('foo bar=baz qux')
        end

        it 'captures the provided value for long flags' do
          stub_commander_runner_args(['--shell_string_1', 'foo bar=baz qux'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:shell_string_1]).to eq('foo bar=baz qux')
        end
      end

      describe 'Integer flags' do
        let(:config_items) do
          [
            FastlaneCore::ConfigItem.new(key: :integer_1,
                                         short_option: '-i',
                                         description: 'Integer 1',
                                         is_string: false,
                                         type: Integer)
          ]
        end

        it 'raises MissingArgument for short flags with missing values' do
          stub_commander_runner_args(['-i'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'raises MissingArgument for long flags with missing values' do
          stub_commander_runner_args(['--integer_1'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'captures the provided value for short flags' do
          stub_commander_runner_args(['-i', '123'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:integer_1]).to eq(123)
        end

        it 'captures the provided value for long flags' do
          stub_commander_runner_args(['--integer_1', '123'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:integer_1]).to eq(123)
        end
      end

      describe 'Float flags' do
        let(:config_items) do
          [
            FastlaneCore::ConfigItem.new(key: :float_1,
                                         short_option: '-f',
                                         description: 'Float 1',
                                         is_string: false,
                                         type: Float)
          ]
        end

        it 'raises MissingArgument for short flags with missing values' do
          stub_commander_runner_args(['-f'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'raises MissingArgument for long flags with missing values' do
          stub_commander_runner_args(['--float_1'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'captures the provided value for short flags' do
          stub_commander_runner_args(['-f', '1.23'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:float_1]).to eq(1.23)
        end

        it 'captures the provided value for long flags' do
          stub_commander_runner_args(['--float_1', '1.23'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:float_1]).to eq(1.23)
        end
      end

      describe 'Boolean flags' do
        let(:config_items) do
          [
            FastlaneCore::ConfigItem.new(key: :boolean_1,
                                         short_option: '-a',
                                         description: 'Boolean 1',
                                         is_string: false)
          ]
        end

        it 'treats short flags with no data type as booleans with true values' do
          stub_commander_runner_args(['-a'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:boolean_1]).to eq(true)
        end

        it 'treats long flags with no data type as booleans with true values' do
          stub_commander_runner_args(['--boolean_1'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:boolean_1]).to eq(true)
        end

        it 'treats short flags with no data type as booleans and captures true values' do
          stub_commander_runner_args(['-a', 'true'])

          program = TestCommanderProgram.run(config_items)

          # At this point in the options lifecycle we're getting the value back as a String
          # this is OK because the Configuration will properly coerce the value when fetched
          expect(program.options[:boolean_1]).to eq('true')
        end

        it 'treats long flags with no data type as booleans and captures true values' do
          stub_commander_runner_args(['--boolean_1', 'true'])

          program = TestCommanderProgram.run(config_items)

          # At this point in the options lifecycle we're getting the value back as a String
          # this is OK because the Configuration will properly coerce the value when fetched
          expect(program.options[:boolean_1]).to eq('true')
        end

        it 'treats short flags with no data type as booleans and captures false values' do
          stub_commander_runner_args(['-a', 'false'])

          program = TestCommanderProgram.run(config_items)

          # At this point in the options lifecycle we're getting the value back as a String
          # this is OK because the Configuration will properly coerce the value when fetched
          expect(program.options[:boolean_1]).to eq('false')
        end

        it 'treats long flags with no data type as booleans and captures false values' do
          stub_commander_runner_args(['--boolean_1', 'false'])

          program = TestCommanderProgram.run(config_items)

          # At this point in the options lifecycle we're getting the value back as a String
          # this is OK because the Configuration will properly coerce the value when fetched
          expect(program.options[:boolean_1]).to eq('false')
        end
      end

      describe 'Array flags' do
        let(:config_items) do
          [
            FastlaneCore::ConfigItem.new(key: :array_1,
                                         short_option: '-a',
                                         description: 'Array 1',
                                         is_string: false,
                                         type: Array)
          ]
        end

        it 'raises MissingArgument for short flags with missing values' do
          stub_commander_runner_args(['-a'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'raises MissingArgument for long flags with missing values' do
          stub_commander_runner_args(['--array_1'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'captures the provided value for short flags' do
          stub_commander_runner_args(['-a', 'a,b,c'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:array_1]).to eq(%w(a b c))
        end

        it 'captures the provided value for long flags' do
          stub_commander_runner_args(['--array_1', 'a,b,c'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:array_1]).to eq(%w(a b c))
        end
      end

      describe 'Multiple flags' do
        let(:config_items) do
          [
            FastlaneCore::ConfigItem.new(key: :string_1,
                                         short_option: '-s',
                                         description: 'String 1',
                                         is_string: true),
            FastlaneCore::ConfigItem.new(key: :array_1,
                                         short_option: '-a',
                                         description: 'Array 1',
                                         is_string: false,
                                         type: Array),
            FastlaneCore::ConfigItem.new(key: :integer_1,
                                         short_option: '-i',
                                         description: 'Integer 1',
                                         is_string: false,
                                         type: Integer),
            FastlaneCore::ConfigItem.new(key: :float_1,
                                         short_option: '-f',
                                         description: 'Float 1',
                                         is_string: false,
                                         type: Float),
            FastlaneCore::ConfigItem.new(key: :boolean_1,
                                         short_option: '-b',
                                         description: 'Boolean 1',
                                         is_string: false)
          ]
        end

        it 'raises MissingArgument for short flags with missing values' do
          stub_commander_runner_args(['-b', '-s'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'raises MissingArgument for long flags with missing values' do
          stub_commander_runner_args(['--boolean_1', '--string_1'])

          expect { TestCommanderProgram.run(config_items) }.to raise_error(OptionParser::MissingArgument)
        end

        it 'captures the provided values for short flags' do
          stub_commander_runner_args(['-b', '-a', 'a,b,c', '-s', 'value'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:boolean_1]).to be(true)
          expect(program.options[:string_1]).to eq('value')
          expect(program.options[:array_1]).to eq(%w(a b c))
        end

        it 'captures the provided values for long flags' do
          stub_commander_runner_args(['--float_1', '1.23', '--boolean_1', 'false', '--integer_1', '123'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:float_1]).to eq(1.23)
          # At this point in the options lifecycle we're getting the value back as a String
          # this is OK because the Configuration will properly coerce the value when fetched
          expect(program.options[:boolean_1]).to eq('false')
          expect(program.options[:integer_1]).to eq(123)
        end

        it 'captures the provided values for mixed flags' do
          stub_commander_runner_args(['-f', '1.23', '-b', '--integer_1', '123'])

          program = TestCommanderProgram.run(config_items)

          expect(program.options[:float_1]).to eq(1.23)
          expect(program.options[:boolean_1]).to eq(true)
          expect(program.options[:integer_1]).to eq(123)
        end
      end
    end
  end
end
