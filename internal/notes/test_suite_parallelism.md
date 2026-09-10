# Speeding up the spec suite: objective, and which methods actually apply

Companion to `internal/order_dependent_specs.md`. That file tracks a specific defect; this one records why the order-dependence work is being done at all, and what the options are once it lands. Written 2026-09-10.

## Objective

Cut the wall clock of the full spec suite. Measured locally on macOS at 236s. The distribution matters more than the total: a four way split by file gives 81s (2.9x), and the slowest single file is 27.8s, which is the floor no form of parallelism gets under. Splitting further than four workers buys very little until that file is itself broken up.

The suite is not CPU bound. Almost all of the time is spent waiting on subprocesses (`xcodebuild`, `security`, `git`) and on real `sleep` calls. That single fact decides which methods are worth trying.

## Prerequisite, and why it comes first

Parallel workers receive an arbitrary subset of the suite in an arbitrary order. Any example that depends on another example having run first will fail intermittently once the split is introduced, and it will fail differently on every run. So the order-dependence work in `order_dependent_specs.md` is not a side quest, it is the thing that has to be finished before any parallelism can be trusted. Running the suite under `--order random` is the cheap way to find those dependencies before a worker split does it for us at a much worse signal to noise ratio.

## Method 1, processes

`parallel_tests` or `turbo_tests`, both of which fork. This is the default choice and it needs no new abstractions in the specs.

Forking gives each worker its own `ENV` and its own working directory, because both are per process in the kernel. Everything the order-dependence effort has been fixing translates directly, and nothing further is required to keep workers from corrupting each other through those two channels.

Cost is memory: every worker carries a full fastlane load.

## Method 2, oversubscribing workers past the core count

GitHub Actions runners are core limited (linux 2, windows 2, macOS 4, or 3 on M1), and it is tempting to read that as the ceiling. It is not, for an I/O bound suite. A core is only contended by work that is actually running; a worker blocked in `waitpid` on `xcodebuild` is not using one. Two cores will keep six workers busy if five of them are waiting.

So the way past the "core limit" is to run more processes than cores and measure, not to reach for threads. Worth benchmarking at 4 and 6 workers on the 2 core Linux runner. RAM is the real constraint here, not CPU.

## Method 3, threads: possible in principle, blocked in practice

MRI's GVL serialises Ruby bytecode but is released around blocking calls. Measured on ruby 3.1.7, 2026-09-09:

```
CPU bound        1 thread 0.16s    4 threads 0.62s    speedup 1.01x
subprocess wait  1 thread 0.51s    4 threads 0.51s    speedup 3.96x
```

So for a suite shaped like this one, threads would overlap the waits about as well as processes do. The obstacle is not the GVL, it is that threads share the things this suite mutates.

**`Dir.chdir` is a process wide syscall.** There is no thread local equivalent, and Ruby does not merely fail to isolate it, it refuses concurrent use outright:

```
thread B: RuntimeError: conflicting chdir during another chdir block
```

Seven spec files chdir. Making them thread safe means rewriting each to use absolute paths, which is a change to the specs under test rather than to the harness.

**`ENV` is likewise process global**, and a thread's writes are immediately visible to every other thread. A `Thread.current` keyed shim installed over `ENV` would cover Ruby side reads only: any `Process.spawn` or backtick call still inherits the real process environment, so one thread's `FASTLANE_TEAM_ID` lands in another thread's subprocess. That makes the leak problem below worse rather than better.

**RSpec itself is not thread safe.** `RSpec.configuration`, the reporter, and the `let`/`before` machinery all assume a single thread, and mocks are installed on shared constants, so `allow(Process).to receive(:wait)` in one thread applies to all of them.

Conclusion: threads are not the route past the core limit, method 2 is. If threads are ever used it should be inside a single worker, for a small set of genuinely independent slow leaves, not as the suite level strategy.

## Method 4, Ractors: out

The only true no GVL option, and incompatible with both RSpec and fastlane as they stand. Ractors cannot share mutable objects, which rules out a shared RSpec configuration and rules out mocking shared constants. Fastlane's own module level state, `Fastlane::Actions.lane_context` and `FastlaneCore::Globals` among others, is exactly what Ractors forbid.

## The ENV guard is not part of this

Worth stating plainly so it does not get dropped when the parallelism plan simplifies. The `ENV` guard in `spec_helper.rb` exists because a spec that leaves a credential behind in the environment is a leak, whatever the concurrency model. At seed 40083 thirty five variables escape their example, led by `FASTLANE_LANE_NAME` (61 examples) and `FASTLANE_PLATFORM_NAME` (35), and including `DELIVER_PASSWORD` (16), `MAILGUN_APIKEY` (3) and `DANGER_GITHUB_API_TOKEN` (1).

Choosing processes over threads removes the need for a per thread `ENV` abstraction, but it does not remove the need to fix these. The plan is unchanged: run the guard in `report` mode to build the inventory, then per example either declare the variable as a legitimate output with `env_output:` metadata or wrap the mutation in `FastlaneSpec::Env.with_env_values`, and finally switch the guard to `enforce` so new leaks fail the build.
