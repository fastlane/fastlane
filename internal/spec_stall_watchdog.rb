# Loaded through RSPEC_ARGS on the tests/ci-stall-probe branch only: when a worker makes no progress for a few seconds,
# records what it is blocked on. Not for merging.
#
# Everything it calls is captured at load time, so a spec that stubs Open3, IO.popen or the clock, or activates
# FakeFS, neither sees these calls nor changes what they do.
module SpecStallWatchdog
  CLOCK = Process.method(:clock_gettime)
  POPEN = IO.method(:popen)
  THRESHOLDS = [3, 10, 30, 60, 120, 300].freeze

  @out = File.open(File.join(ENV.fetch("PROBE_DIR", "probe"), "stall_worker_#{ENV.fetch('FASTLANE_SPEC_WORKER', $$)}.log"), "a")
  @out.sync = true
  @mutex = Mutex.new
  @mark = ["loading", CLOCK.call(Process::CLOCK_MONOTONIC)]

  class << self
    # Called at the start and end of each example: a stall is measured from the last one, so time spent in
    # before(:context) hooks or loading a file counts too.
    def mark(label)
      now = CLOCK.call(Process::CLOCK_MONOTONIC)
      previous, since = @mutex.synchronize do
        last = @mark
        @mark = [label, now]
        last
      end
      # The exact time of every slow example, which the dumps only bound
      @out.puts("=== #{wall} took #{format('%.1f', now - since)}s: #{previous}") if previous.start_with?("start of ") && now - since >= 1
    end

    def wall
      Time.at(CLOCK.call(Process::CLOCK_REALTIME)).utc.strftime("%H:%M:%S.%L")
    end

    def run(command)
      POPEN.call(command, err: [:child, :out], &:read)
    rescue StandardError => e
      "#{command.first} failed: #{e.class}: #{e.message}"
    end

    # This worker's descendants, from one ps listing
    def descendants
      rows = run(["ps", "-axo", "pid=,ppid=,etime=,%cpu=,rss=,state=,command="]).lines.map { |line| line.strip.split(/\s+/, 7) }
      found = [Process.pid]
      loop do
        added = rows.select { |row| found.include?(row[1].to_i) && !found.include?(row[0].to_i) }.map { |row| row[0].to_i }
        break if added.empty?
        found += added
      end
      rows.select { |row| found.include?(row[0].to_i) && row[0].to_i != Process.pid && !row[6].to_s.start_with?("ps ") }
    end

    def dump(label, seconds, first)
      @out.puts("=== #{wall} worker #{ENV['FASTLANE_SPEC_WORKER']} pid #{Process.pid}: no progress for #{seconds}s, since #{label}")
      children = descendants
      @out.puts("--- children (pid ppid etime %cpu rss state command)")
      children.each { |row| @out.puts(row.join(" ")) }
      Thread.list.each do |thread|
        next if thread == Thread.current
        @out.puts("--- thread #{thread.inspect}")
        (thread.backtrace || []).reject { |frame| frame.include?("/gems/rspec-") }.first(25).each { |frame| @out.puts("    #{frame}") }
      end
      # Once per stall: a one second sample of each child shows where it is waiting
      if first
        children.each do |row|
          @out.puts("--- sample #{row[0]} #{row[6]}")
          @out.puts(run(["sample", row[0], "1"]).split("Binary Images:").first)
        end
      end
      @out.puts("=== #{wall} end of dump")
    end

    def start
      Thread.new do
        reported = nil
        loop do
          sleep(0.5)
          label, since = @mutex.synchronize { @mark }
          stalled = CLOCK.call(Process::CLOCK_MONOTONIC) - since
          threshold = THRESHOLDS.reverse.find { |t| stalled >= t }
          next if threshold.nil? || reported == [since, threshold]
          dump(label, threshold, reported.nil? || reported.first != since)
          reported = [since, threshold]
        end
      end
    end
  end
end

SpecStallWatchdog.start

RSpec.configure do |config|
  config.before(:each) { |example| SpecStallWatchdog.mark("start of #{example.id} #{example.full_description}") }
  config.after(:each) { |example| SpecStallWatchdog.mark("end of #{example.id}") }
end
