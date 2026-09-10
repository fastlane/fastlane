# Runs the suite as several independent rspec processes, see fastlane#30184.
#
# Splitting is its own kind of ordering: a worker sees a subset no random seed
# ever produces, such as the spaceship specs with no fastlane spec having run
# first. Worth running alongside the random order audit rather than after it.
#
# Separate processes, not threads, because ENV and the working directory are
# per process in the kernel. A worker cannot corrupt another through either.
#
#   rake test_parallel                 workers chosen from the timings
#   WORKERS=4 rake test_parallel
#   WORKERS=6 RSPEC_ARGS="--order random" rake test_parallel
SPEC_TIMINGS = "internal/spec_timings.json".freeze

# How long a unit of work may be before it is worth cutting up, as a fraction of
# a worker's share. A file at 1.3 times the share cannot be balanced away: some
# worker has to run it and everyone else waits.
SPLIT_THRESHOLD = 1.05

def spec_files
  files = (Dir.glob("spec/**/*_spec.rb") + Dir.glob("*/spec/**/*_spec.rb")).uniq
  excluded = ENV["EXCLUDE"].to_s.split
  return files if excluded.empty?

  # Space separated paths to leave out. For specs that fail under a split for a
  # reason that is not ordering, so that a real finding is not buried under a
  # known one. Say which, every run, so an exclusion cannot quietly become
  # permanent.
  kept = files.reject { |file| excluded.include?(file.delete_prefix("./")) }
  puts("Excluding #{files.size - kept.size} file(s) by EXCLUDE: #{excluded.join(', ')}")
  kept
end

def load_timings
  return { "files" => {}, "examples" => {} } unless File.exist?(SPEC_TIMINGS)

  data = JSON.parse(File.read(SPEC_TIMINGS))
  data.key?("files") ? data : { "files" => data, "examples" => {} } # older flat format
end

# Longest processing time first: give the heaviest unit to whichever worker has
# least queued. Within about 4/3 of optimal for this shape of problem, and the
# tail is what sets the wall clock.
def pack(units, workers)
  buckets = Array.new(workers) { [] }
  weights = Array.new(workers, 0.0)
  units.sort_by { |_name, seconds| -seconds }.each do |name, seconds|
    lightest = weights.each_with_index.min_by { |weight, _index| weight }[1]
    buckets[lightest] << name
    weights[lightest] += seconds
  end
  [buckets.reject(&:empty?), weights]
end

# A file heavier than the threshold is cut into runs of examples, addressed with
# rspec's own `path[id,id]` syntax. Without this the slowest single file is a
# floor no number of workers gets under: at 269s total and a 35s worst file,
# seven workers is the most that can help.
def units_for(files, timings, target)
  files.flat_map do |file|
    key = file.delete_prefix("./")
    seconds = timings["files"][key] || 0.05
    examples = timings["examples"][key]

    next [[file, seconds]] if examples.nil? || seconds <= target * SPLIT_THRESHOLD

    chunks = [[]]
    running = 0.0
    examples.sort_by { |_id, secs| -secs }.each do |id, secs|
      if running + secs > target && !chunks.last.empty?
        chunks << []
        running = 0.0
      end
      chunks.last << id
      running += secs
    end
    chunks.map { |ids| ["#{file}[#{ids.join(',')}]", ids.sum { |id| examples[id] }] }
  end
end

desc("Record per file and per example spec durations for test_parallel to balance on")
task(:spec_timings) do
  require "json"

  out = "rspec_timings_raw.json"
  # --out, not a shell redirect: spec_helper.rb repoints $stdout at a temporary
  # file, so a redirect captures nothing.
  #
  # A failing example still has a duration, and this task is for timings rather
  # than for verdicts, so a non-zero exit is not a reason to stop. `sh` aborts
  # on one unless it is given a block.
  sh("rspec --pattern 'spec/**/*_spec.rb,*/spec/**/*_spec.rb' --format json --out #{out}") { |_ok, _res| }
  raise("rspec produced no #{out}") unless File.exist?(out)

  files = Hash.new(0.0)
  examples = Hash.new { |hash, key| hash[key] = {} }
  JSON.parse(File.read(out))["examples"].each do |example|
    path = example["file_path"].delete_prefix("./")
    seconds = example["run_time"].to_f
    files[path] += seconds
    examples[path][example["id"][/\[(.*)\]/, 1]] = seconds
  end

  # Per example timings only for what might need splitting. Keeping all of them
  # would be a megabyte of ids nothing reads.
  heavy = files.select { |_path, seconds| seconds > 5.0 }.keys
  File.write(SPEC_TIMINGS, JSON.pretty_generate(
                             "files" => files.sort_by { |_path, seconds| -seconds }.to_h,
                             "examples" => examples.select { |path, _| heavy.include?(path) }
  ))
  File.delete(out)

  puts("Wrote #{files.size} file timings (#{heavy.size} with per example detail) to #{SPEC_TIMINGS}, #{files.values.sum.round}s total")
end

desc("Run the suite as WORKERS independent rspec processes")
task(:test_parallel) do
  require "etc"
  require "json"

  timings = load_timings
  files = spec_files
  total = timings["files"].values.sum

  # Derived rather than fixed per platform, because what decides the number is
  # the core count and how much of the suite shells out, not the operating
  # system name. Measured: a 14 core machine flattens after eight workers, 50s
  # against 276s sequential, and a macOS runner peaks at four, 263s against
  # 562s, where six is slower than four. `min(cores, 8)` fits both.
  #
  # The cap is there because each worker spawns an xcodebuild child and waits on
  # it, so N workers is nearer 2N runnable processes and a big machine
  # oversubscribes long before it runs out of cores. If the xcodebuild specs
  # ever stop shelling out, this cap should be revisited upwards. Linux and
  # Windows skip those specs entirely, so their shape is different again.
  #
  # WORKERS overrides it, which is the point: measure on your own machine.
  workers = Integer(ENV["WORKERS"] || [Etc.nprocessors, 8].min)
  target = total.positive? ? total / workers : 0

  units = units_for(files, timings, target)
  buckets, weights = pack(units, workers)

  source = total.zero? ? "file size, run `rake spec_timings` first" : "measured durations"
  split = units.size - files.size
  puts("Running #{files.size} spec files as #{buckets.size} processes on #{Etc.nprocessors} cores, balanced by #{source}")
  puts("#{split} extra unit(s) from cutting up files heavier than one worker's share") if split.positive?
  unless total.zero?
    spread = weights.reject(&:zero?)
    puts(format("Predicted worker load %<min>.0fs to %<max>.0fs", min: spread.min, max: spread.max))
  end

  started = Time.now
  pids = buckets.each_with_index.map do |bucket, index|
    log = "rspec_worker_#{index}.log"
    # Record the split, so a failure that only happens under one can be replayed
    # by handing these paths straight back to rspec.
    File.write(log, "# worker #{index}, #{bucket.size} units\n# #{bucket.join(' ')}\n")
    command = ["rspec", "--format", "progress", *ENV["RSPEC_ARGS"].to_s.split, *bucket]
    Process.spawn(*command, out: [log, "a"], err: [log, "a"])
  end

  results = pids.map { |pid| Process.wait2(pid).last }
  elapsed = Time.now - started

  results.each_with_index do |status, index|
    tail = File.readlines("rspec_worker_#{index}.log").grep(/examples?,/).last.to_s.strip
    puts(format("  worker %<index>d  exit %<exit>-3d %<tail>s",
                index: index, exit: status.exitstatus, tail: tail))
  end
  puts(format("Wall clock %<elapsed>.1fs across %<workers>d processes",
              elapsed: elapsed, workers: buckets.size))

  failed = results.each_with_index.reject { |status, _index| status.success? }

  # No `return` here: this is a block, and returning from one raises
  # LocalJumpError, which is what it did on CI.
  unless failed.empty?
    # The worker logs stay on disk, so without this a CI log says only how many
    # examples failed and never which. Print the failures and the split that
    # produced them, since a split only failure cannot be reproduced without
    # knowing what the worker was given.
    failed.each do |_status, index|
      log = File.readlines("rspec_worker_#{index}.log")
      puts("")
      puts("worker #{index} failures:")
      log.grep(%r{^rspec \./}).each { |line| puts("  #{line.strip}") }
      puts("  units: #{log[1].to_s.sub('# ', '').strip}")
    end
    abort("#{failed.size} of #{results.size} workers failed")
  end
end
