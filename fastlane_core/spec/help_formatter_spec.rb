describe FastlaneCore::HelpFormatter do
  class MockCommand
    attr_accessor :name, :summary, :description, :options, :examples

    def initialize(name, summary, description, options, examples)
      @name = name
      @summary = summary
      @description = description
      @options = options
      @examples = examples
    end
  end

  class MockCommanderRunner
    attr_accessor :commands, :program, :options, :aliases, :default_command

    def initialize
      @commands = {}
      @program = {}
      @options = []
      @aliases = {}
      @default_command = nil
    end

    def program(key)
      @program[key]
    end

    def alias?(name)
      @aliases.include?(name)
    end
  end

  let(:commander) { MockCommanderRunner.new }

  before do
    commander.program = {
      name: 'foo_bar_test',
      description: 'This is a mock CLI app for testing'
    }
    default_command_options = [
      {
        switches: ['-v', '--verbose'],
        description: 'Output verbose logs'
      }
    ]
    commander.commands = {
      foo: MockCommand.new('foo', 'Print foo', 'Print foo description', [], []),
      bar: MockCommand.new('bar', 'Print bar', 'Print bar description', [], []),
      foo_bar: MockCommand.new('foo_bar', 'Print foo bar', 'Print foo bar description', default_command_options, [])
    }
  end

  it 'should indicate default command with default_command setting' do
    commander.default_command = :foo_bar
    help = described_class.new(commander).render
    expect(help).to match(/\(\* default\)/)
    expect(help).to match(/\* Print foo bar/)
  end

  it 'should not mention default command with without default_command setting' do
    help = described_class.new(commander).render
    expect(help).not_to match(/\(\* default\)/)
    expect(help).not_to match(/\* Print foo bar/)
  end

  it 'should still renders a subcommand with super class\'s template' do
    command = commander.commands[:foo]
    help = described_class.new(commander).render_command(command)
    expect(help).to match(/#{command.description}/)
  end
end
