require 'fastlane/server/socket_server'
require 'fastlane/commands_generator'

describe Fastlane::SocketServer do
  let(:addresses) { Addrinfo.getaddrinfo('localhost', nil, nil, :STREAM).map(&:ip_address).uniq }

  # Starts the server in a thread, and waits until it listens or gives up.
  def start(server)
    thread = Thread.new do
      Thread.current.report_on_exception = false
      server.start
    end
    sleep(0.05) while thread[:ready].nil? && thread.alive?
    thread
  end

  def listening?(ip, port)
    Addrinfo.tcp(ip, port).listen.close
    false
  rescue Errno::EADDRINUSE
    true
  end

  # Connects like the runner and sends the old style done command, which shuts the server down.
  def finish(thread, ip)
    Socket.tcp(ip, thread[:port]) { |runner| runner.write('done') }
    expect(thread.join(5)).to be(thread)
  end

  # Windows lets a socket bind a port another one listens on (Ruby sets SO_REUSEADDR), so a taken port goes unnoticed there
  it 'listens on every address localhost resolves to, on one free port', unless: FastlaneCore::Helper.windows? do
    thread = start(described_class.new(port: 0))

    expect(thread[:port]).to be > 0
    addresses.each { |ip| expect(listening?(ip, thread[:port])).to be(true), "not listening on #{ip}" }

    finish(thread, addresses.first)
  end

  it 'refuses to start when another process listens on one of those addresses, rather than using the others', unless: FastlaneCore::Helper.windows? do
    # The runner tries the addresses of `localhost` in this order, so whoever holds the first one gets its commands.
    squatter = Addrinfo.tcp(addresses.first, 0).listen
    port = squatter.local_address.ip_port

    thread = start(described_class.new(port: port, connection_timeout: 1))

    expect { thread.join(5) }.to raise_error(FastlaneCore::Interface::FastlaneError, /could not listen on .*#{port}/)
    expect(thread[:ready]).to be_nil
    addresses.drop(1).each { |ip| expect(listening?(ip, port)).to be(false), "left listening on #{ip}" }
  ensure
    squatter&.close
  end

  it 'accepts the first connection on any of those addresses, then stops listening' do
    thread = start(described_class.new(port: 0))
    port = thread[:port]

    Socket.tcp(addresses.last, port) do |runner|
      Timeout.timeout(5) { sleep(0.05) while addresses.any? { |ip| listening?(ip, port) } }
      runner.write('done')
    end

    expect(thread.join(5)).to be(thread)
  end

  describe 'with a token' do
    let(:executor) { double('command executor') }
    let(:token) { 'a' * 64 }
    let(:action) { { commandType: 'action', command: { commandID: '1', methodName: 'sh', args: [] } } }

    # Sends one command the way the runner does, and returns what the server answered before closing.
    def send_command(thread, command)
      Socket.tcp(addresses.first, thread[:port]) do |client|
        client.write(command)
        client.read
      end
    end

    it 'refuses a command without the token, before running it' do
      expect(executor).not_to receive(:execute)
      thread = start(described_class.new(command_executor: executor, port: 0, token: token))

      expect(send_command(thread, action.to_json)).to be_empty
      expect(thread.join(5)).to be(thread)
    end

    it 'refuses a command with another token' do
      expect(executor).not_to receive(:execute)
      thread = start(described_class.new(command_executor: executor, port: 0, token: token))

      send_command(thread, action.merge(token: 'b' * 64).to_json)
      expect(thread.join(5)).to be(thread)
    end

    it 'runs a command with the token' do
      expect(executor).to receive(:execute).and_raise('reached the executor')
      thread = start(described_class.new(command_executor: executor, port: 0, token: token))

      reply = Socket.tcp(addresses.first, thread[:port]) do |client|
        client.write(action.merge(token: token).to_json)
        client.gets # the server reports the action's error, then waits for the next command
      end

      expect(reply).to include('reached the executor')
      expect(thread.join(5)).to be(thread)
    end
  end
end

describe Fastlane::SwiftLaneManager do
  before do
    allow(described_class).to receive(:ensure_runner_built!)
    allow(described_class).to receive(:finish_fastlane)
    allow(described_class).to receive(:runner_sends_token?).and_return(true)
    allow(described_class).to receive(:warn_if_runner_outdated)
  end

  it 'lets the server pick a free port and gives that port to the runner' do
    server_thread = Thread.new do
      Thread.current[:port] = 51_234
      Thread.current[:ready] = true
      Thread.current[:exit_reason] = :done
    end
    server_thread.join
    expect(described_class).to receive(:start_socket_thread).with(port: 0, token: anything).and_return(server_thread)
    expect(described_class).to receive(:cruise_swift_lane_in_thread).with('test', {}, 51_234, kind_of(String))

    described_class.cruise_lane('test', {}, disable_runner_upgrades: true)
  end

  it 'reports why the server could not listen, instead of waiting for it forever' do
    server_thread = Thread.new do
      Thread.current.report_on_exception = false
      FastlaneCore::UI.user_error!('fastlane could not listen on [::1]:2000')
    end
    allow(described_class).to receive(:start_socket_thread).and_return(server_thread)
    expect(described_class).not_to receive(:cruise_swift_lane_in_thread)
    expect(FastlaneCore::UI).to receive(:error).with(/could not listen/)

    Timeout.timeout(5) { described_class.cruise_lane('test', {}, disable_runner_upgrades: true) }
  end

  describe 'the token' do
    let(:server_thread) do
      Thread.new do
        Thread.current[:port] = 51_234
        Thread.current[:ready] = true
      end.tap(&:join)
    end

    it 'is written to a file only this user can read, given to the runner, and removed after the lane' do
      server_token = nil
      allow(described_class).to receive(:start_socket_thread) { |port:, token:| server_token = token }.and_return(server_thread)
      token_file = nil
      expect(described_class).to receive(:cruise_swift_lane_in_thread) do |_lane, _parameters, _port, file|
        token_file = file
        expect(File.stat(File.dirname(file)).mode & 0o777).to be == 0o700
        expect(File.stat(file).mode & 0o777).to be == 0o600
        expect(File.read(file)).to be == server_token
      end

      described_class.cruise_lane('test', {}, disable_runner_upgrades: true)

      expect(server_token).to match(/\A\h{64}\z/)
      expect(File.exist?(File.dirname(token_file))).to be(false)
    end

    it 'is not required from a runner that does not send it' do
      allow(described_class).to receive(:runner_sends_token?).and_return(false)
      expect(described_class).to receive(:start_socket_thread).with(port: 0, token: nil).and_return(server_thread)
      allow(described_class).to receive(:cruise_swift_lane_in_thread)

      described_class.cruise_lane('test', {}, disable_runner_upgrades: true)
    end
  end

  describe '.runner_sends_token?' do
    let(:runner) { Tempfile.new('FastlaneRunner') }

    before do
      allow(FastlaneCore::FastlaneFolder).to receive(:swift_runner_path).and_return(runner.path)
      allow(described_class).to receive(:runner_sends_token?).and_call_original
    end

    after { runner.close! }

    it 'is true for a runner built with the protocol version' do
      File.binwrite(runner.path, "\xCF\xFA\xED\xFE\x00FastlaneRunnerProtocolVersion [2]\x00".b)
      expect(described_class.runner_sends_token?).to be(true)
    end

    it 'is false for a protocol version 1 runner, from before the token' do
      File.binwrite(runner.path, "\xCF\xFA\xED\xFE\x00FastlaneRunnerProtocolVersion [1]\x00".b)
      expect(described_class.runner_sends_token?).to be(false)
    end

    it 'is false for a runner from before it' do
      File.binwrite(runner.path, "\xCF\xFA\xED\xFE\x00".b)
      expect(described_class.runner_sends_token?).to be(false)
    end
  end
end

describe 'fastlane socket_server' do
  let(:server) { double('socket server', start: nil) }

  # The command line also checks for plugin updates in the background, over the network
  before { allow(Fastlane::PluginUpdateManager).to receive(:start_looking_for_updates) }

  around do |example|
    Dir.mktmpdir('socket-server') do |dir|
      @dir = dir
      example.run
    end
  end

  def run_command(*args)
    stub_commander_runner_args(['socket_server', *args])
    Fastlane::CommandsGenerator.start
  end

  it 'requires the token read from --token_file' do
    token_file = File.join(@dir, 'token')
    File.write(token_file, "#{'a' * 64}\n", perm: 0o600)
    expect(Fastlane::SocketServer).to receive(:new).with(hash_including(token: 'a' * 64)).and_return(server)

    run_command('--token_file', token_file)
  end

  it 'refuses an empty token file rather than accepting any command' do
    token_file = File.join(@dir, 'token')
    File.write(token_file, "\n", perm: 0o600)
    expect(Fastlane::SocketServer).not_to receive(:new)

    expect { run_command('--token_file', token_file) }.to raise_error(SystemExit, /is empty/)
  end

  it 'warns that any local process can connect without --token_file' do
    expect(FastlaneCore::UI).to receive(:important).with(/No --token_file given/)
    expect(Fastlane::SocketServer).to receive(:new).with(hash_including(token: nil)).and_return(server)

    run_command
  end

  it 'reads the token file from FASTLANE_SOCKET_SERVER_TOKEN_FILE, as the Swift package runner sets it' do
    token_file = File.join(@dir, 'token')
    File.write(token_file, 'b' * 64, perm: 0o600)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('FASTLANE_SOCKET_SERVER_TOKEN_FILE').and_return(token_file)
    expect(Fastlane::SocketServer).to receive(:new).with(hash_including(token: 'b' * 64)).and_return(server)

    run_command
  end
end

describe Fastlane::SocketServerActionCommandExecutor do
  it "reports an unknown action" do
    expect do
      Fastlane::SocketServerActionCommandExecutor.new.class_ref_for_action(named: "no_such_action_xyz")
    end.to raise_error(FastlaneCore::Interface::FastlaneError, /Action 'no_such_action_xyz' not available/)
  end
end
