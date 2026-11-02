# Loaded by `rake spec_timings` on the tests/ci-timing-probe branch only: records
# where example time goes on the CI runners. Not for merging.
require "json"
require "open3"

module SpecProbe
  @sites = Hash.new { |h, k| h[k] = { "n" => 0, "t" => 0.0, "examples" => {} } }
  @setup = Hash.new { |h, k| h[k] = { "n" => 0, "t" => 0.0 } }
  @current = nil
  @depth = 0

  class << self
    attr_accessor :current

    def now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    # Outermost call only, so Open3.capture2e and the popen it calls count once
    def time(kind, label)
      return yield if @depth > 0
      @depth += 1
      start = now
      begin
        yield
      ensure
        @depth -= 1
        record(kind, label, now - start)
      end
    end

    def record(kind, label, seconds)
      return if seconds < 0.003
      locations = caller_locations(3, 30).map(&:to_s).reject { |l| l.include?("spec_probe") || l.include?("/gems/") || l.include?("<internal") }
      site = locations.find { |l| l.include?("/lib/") } || locations.first || "?"
      site = site.sub(Dir.pwd + "/", "").sub(/:in .*/, "")
      key = "#{kind} #{site} :: #{label.to_s.gsub(/\s+/, ' ')[0, 80]}"
      entry = @sites[key]
      entry["n"] += 1
      entry["t"] += seconds
      entry["examples"][@current] = (entry["examples"][@current] || 0) + seconds if @current
    end

    def setup_time(label)
      start = now
      begin
        yield
      ensure
        @setup[label]["n"] += 1
        @setup[label]["t"] += now - start
      end
    end

    def write(path)
      sites = @sites.map { |key, e| { "site" => key, "n" => e["n"], "t" => e["t"].round(4), "examples" => e["examples"].transform_values { |v| v.round(4) } } }
      File.write(path, JSON.pretty_generate("sites" => sites.sort_by { |s| -s["t"] }, "spaceship_setup" => @setup))
    end
  end

  module DirProbe
    def [](*args, **kwargs, &block)
      SpecProbe.time("glob", args.first) { super }
    end

    def glob(*args, **kwargs, &block)
      SpecProbe.time("glob", args.first) { super }
    end
  end

  module KernelProbe
    def `(command)
      SpecProbe.time("backtick", command) { super }
    end

    def system(*args, **kwargs)
      SpecProbe.time("system", args.join(" ")) { super }
    end

    def spawn(*args, **kwargs)
      SpecProbe.time("spawn", args.join(" ")) { super }
    end
  end

  module Open3Probe
    %i[capture2 capture2e capture3 popen2 popen2e popen3].each do |name|
      define_method(name) do |*args, **kwargs, &block|
        SpecProbe.time("open3", args.reject { |a| a.kind_of?(Hash) }.join(" ")) { super(*args, **kwargs, &block) }
      end
    end
  end
end

Dir.singleton_class.prepend(SpecProbe::DirProbe)
Object.prepend(SpecProbe::KernelProbe)
Open3.singleton_class.prepend(SpecProbe::Open3Probe)

RSpec.configure do |config|
  config.before(:suite) do
    # The spaceship setup every spaceship example pays: the global stubs and the two logins
    if Object.private_method_defined?(:before_each_spaceship)
      original = Object.instance_method(:before_each_spaceship)
      Object.send(:define_method, :before_each_spaceship) { SpecProbe.setup_time("before_each_spaceship") { original.bind_call(self) } }
      [Spaceship::Tunes, Spaceship::Portal].each do |mod|
        login = mod.method(:login)
        mod.define_singleton_method(:login) { |*a, **k, &b| SpecProbe.setup_time("#{mod}.login") { login.call(*a, **k, &b) } }
      end
    end
  end

  config.around(:each) do |example|
    SpecProbe.current = example.id
    example.run
    SpecProbe.current = nil
  end

  config.after(:suite) { SpecProbe.write("spec_probe.json") }
end
