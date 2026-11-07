# One example per behaviour and per way of running a command. Where a method behaves differently it is
# pending, with the reason: RSpec fails a pending example that passes, so a difference fixed elsewhere
# shows up here until it is marked uniform.
describe "Running a command with sh, run and execute", unless: FastlaneCore::Helper.windows? do
  # A child Ruby, which exists wherever the specs run
  def ruby(script, *arguments)
    [RbConfig.ruby, "-e", script, *arguments]
  end

  # Calls one of the three the way a caller would, with command and output printing off
  def call(method, arguments, env: nil, **options)
    case method
    when :sh
      Fastlane::Actions.sh(*[env].compact, *arguments, log: false, **options)
    when :run
      FastlaneCore::CommandExecutor.run(*[env].compact, *arguments, print_command: false, **options)
    when :execute
      FastlaneCore::CommandExecutor.execute(command: arguments.shelljoin, print_command: false, suppress_error_output: true, env: env || {}, **options)
    end
  end

  def self.behaviour(name, differs: {}, &check)
    [:sh, :run, :execute].each do |method|
      it "#{method} #{name}" do
        pending(differs[method]) if differs.key?(method)
        instance_exec(method, &check)
      end
    end
  end

  before do
    allow(FastlaneCore::Helper).to receive(:sh_enabled?).and_return(true)
    allow(FastlaneCore::UI).to receive(:command)
    allow(FastlaneCore::UI).to receive(:command_output)
    allow(FastlaneCore::UI).to receive(:error)
  end

  behaviour "gives env to the command only" do |method|
    expect(call(method, ruby("puts ENV['FL_SPEC_UNIFORM']"), env: { "FL_SPEC_UNIFORM" => "set" }).strip).to eq("set")
    expect(ENV.key?("FL_SPEC_UNIFORM")).to be(false)
  end

  behaviour "runs the command in chdir, leaving fastlane's directory alone" do |method|
    Dir.mktmpdir do |dir|
      expect(call(method, ruby("puts Dir.pwd"), chdir: dir).strip).to eq(File.realpath(dir))
      expect(Dir.pwd).not_to eq(File.realpath(dir))
    end
  end

  behaviour "names the signal when the command is killed" do |method|
    # execute takes a shell string: the shell Ruby starts must kill itself, as Ubuntu's dash would wait for an inner one and exit 137
    killed = if method == :execute
               -> { FastlaneCore::CommandExecutor.execute(command: "kill -9 $$", print_command: false, suppress_error_output: true) }
             else
               -> { call(method, ruby("Process.kill(:KILL, Process.pid)")) }
             end
    expect(&killed).to raise_error(/killed by SIGKILL/)
  end

  behaviour "reads the output as UTF-8 whatever the default encoding" do |method|
    previous = [Encoding.default_external, Encoding.default_internal]
    Encoding.default_external = Encoding::US_ASCII
    Encoding.default_internal = nil
    output = call(method, ruby("$stdout.write [99, 97, 102, 195, 169, 10].pack('C*')"))
    expect(output.chomp).to eq("café")
  ensure
    Encoding.default_external, Encoding.default_internal = previous
  end

  behaviour "raises a fastlane error when the command fails" do |method|
    expect { call(method, ruby("exit 3")) }.to raise_error(FastlaneCore::Interface::FastlaneException)
  end

  behaviour "gives the command an empty input when no stdin is given",
            differs: { execute: "an end-of-file on its terminal would echo ^D into the output" } do |method|
    expect(Timeout.timeout(2) { call(method, ruby("print $stdin.read.inspect")) }.strip).to eq('""')
  end

  behaviour "gives stdin data to the command", differs: { execute: "has no stdin:" } do |method|
    expect(call(method, ruby("print $stdin.read"), stdin: "data")).to eq("data")
  end

  behaviour "returns stdout alone with separate_stderr", differs: { execute: "reads one terminal, where stdout and stderr are merged" } do |method|
    expect(call(method, ruby("print 'out'; $stderr.puts 'err'"), separate_stderr: true)).to eq("out")
  end

  behaviour "returns the output as the command wrote it, final newline included", differs: { execute: "drops the final newline; kept in 3.0" } do |method|
    expect(call(method, ruby("puts 'out'"))).to eq("out\n")
  end

  behaviour "raises a fastlane error naming the program when it does not exist",
            differs: { sh: "raises Errno::ENOENT; a fastlane error in 3.0", execute: "raises FastlanePtyError \"fork failed\"" } do |method|
    expect { call(method, ["fl-no-such-program"]) }.to raise_error(FastlaneCore::Interface::FastlaneException, /fl-no-such-program/)
  end

  behaviour "passes an array of arguments as given, without a shell",
            differs: { execute: "joins an array with spaces for a shell; separate arguments in 3.0" } do |method|
    arguments = ruby("print ARGV.inspect", "a b;c")
    output = if method == :execute
               FastlaneCore::CommandExecutor.execute(command: arguments, print_command: false, suppress_error_output: true)
             else
               call(method, arguments)
             end
    expect(output).to eq('["a b;c"]')
  end
end
