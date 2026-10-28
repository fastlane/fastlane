require_relative 'test_commander_program'

# Necessary, as we're now running this in a different context
def stub_request(*args)
  WebMock::API.stub_request(*args)
end

def stub_commander_runner_args(args)
  runner = Commander::Runner.new(args)
  allow(Commander::Runner).to receive(:instance).and_return(runner)
end

def capture_stds
  require "stringio"
  orig_stdout = $stdout
  orig_stderr = $stderr
  $stdout = StringIO.new
  $stderr = StringIO.new
  yield if block_given?
  [$stdout.string, $stderr.string]
ensure
  $stdout = orig_stdout
  $stderr = orig_stderr
end
