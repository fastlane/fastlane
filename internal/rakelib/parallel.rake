# Runs the suite as several independent rspec processes, see fastlane#30184.
#
# A spike rather than a replacement for `test_all`. The point is to find out
# what breaks when the suite is split, and splitting is its own kind of
# ordering: a worker sees a subset no random seed ever produces, such as the
# spaceship specs with no fastlane spec having run first. So this is worth
# running alongside the random order audit rather than after it.
#
# Separate processes, not threads, because ENV and the working directory are
# per process in the kernel. A forked worker cannot corrupt another one through
# either, which is what makes this safe to try before every leak is fixed.
#
#   rake test_parallel                 workers default to the processor count
#   WORKERS=4 rake test_parallel
#   WORKERS=6 RSPEC_ARGS="--order random" rake test_parallel
SPEC_TIMINGS = "internal/spec_timings.json".freeze

# Records how long each spec file takes, so test_parallel can balance on
# something better than file size. Cheap to refresh and safe to leave stale:
# a missing file just means a worse split, never a wrong one.
desc("Record per file spec durations for test_parallel to balance on")
task(:spec_timings) do
  require "json"

  out = "rspec_timings_raw.json"
  sh("rspec --pattern 'spec/**/*_spec.rb,*/spec/**/*_spec.rb' --dry-run=false --format json --out #{out}")

  totals = Hash.new(0.0)
  JSON.parse(File.read(out))["examples"].each do |example|
    totals[example["file_path"].delete_prefix("./")] += example["run_time"].to_f
  end
  File.write(SPEC_TIMINGS, JSON.pretty_generate(totals.sort_by { |_file, seconds| -seconds }.to_h))
  File.delete(out)

  puts("Wrote #{totals.size} file timings to #{SPEC_TIMINGS}, #{totals.values.sum.round}s total")
end

desc("Run the suite as WORKERS independent rspec processes")
task(:test_parallel) do
  require "etc"
  require "json"

  workers = Integer(ENV["WORKERS"] || Etc.nprocessors)
  files = (Dir.glob("spec/**/*_spec.rb") + Dir.glob("*/spec/**/*_spec.rb")).uniq

  # Weight by measured duration where we have it. File size is a poor stand in:
  # one xcodebuild example outweighs a thousand pure ones, and weighting by size
  # put 4006 examples in one worker against 1195 in another. `rake
  # spec_timings` records real per file durations; without that file we fall
  # back to size and say so.
  timings = File.exist?(SPEC_TIMINGS) ? JSON.parse(File.read(SPEC_TIMINGS)) : {}
  weight_of = lambda do |file|
    timings[file] || timings[file.delete_prefix("./")] || (timings.empty? ? File.size(file) : 0.05)
  end

  # Longest processing time first: give the heaviest file to whichever worker
  # has least queued. Optimal within about 4/3 of perfect for this shape of
  # problem, and the tail is what sets the wall clock.
  buckets = Array.new(workers) { [] }
  weights = Array.new(workers, 0.0)
  files.sort_by { |file| -weight_of.call(file) }.each do |file|
    lightest = weights.each_with_index.min_by { |weight, _index| weight }[1]
    buckets[lightest] << file
    weights[lightest] += weight_of.call(file)
  end
  buckets.reject!(&:empty?)

  source = timings.empty? ? "file size, run `rake spec_timings` for durations" : "measured durations"
  puts("Running #{files.size} spec files as #{buckets.size} processes, balanced by #{source}")
  unless timings.empty?
    spread = weights.reject(&:zero?)
    puts(format("Predicted worker load %<min>.0fs to %<max>.0fs", min: spread.min, max: spread.max))
  end

  started = Time.now
  pids = buckets.each_with_index.map do |bucket, index|
    log = "rspec_worker_#{index}.log"
    command = ["rspec", "--format", "progress", *ENV["RSPEC_ARGS"].to_s.split, *bucket]
    Process.spawn(*command, out: log, err: [log, "a"])
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

  failed = results.reject(&:success?)
  abort("#{failed.size} of #{results.size} workers failed") unless failed.empty?
end
