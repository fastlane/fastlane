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
desc("Run the suite as WORKERS independent rspec processes")
task(:test_parallel) do
  require "etc"

  workers = Integer(ENV["WORKERS"] || Etc.nprocessors)
  files = (Dir.glob("spec/**/*_spec.rb") + Dir.glob("*/spec/**/*_spec.rb")).uniq

  # Longest processing time first: assign the biggest file to whichever worker
  # has least queued. File size is a rough stand in for duration, but the tail
  # is what sets the wall clock and this at least keeps the big files apart.
  buckets = Array.new(workers) { [] }
  weights = Array.new(workers, 0)
  files.sort_by { |file| -File.size(file) }.each do |file|
    lightest = weights.each_with_index.min_by { |weight, _index| weight }[1]
    buckets[lightest] << file
    weights[lightest] += File.size(file)
  end
  buckets.reject!(&:empty?)

  puts("Running #{files.size} spec files as #{buckets.size} processes")

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
