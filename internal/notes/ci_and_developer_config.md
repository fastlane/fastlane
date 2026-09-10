# What to run, where, and with how many workers

Measured on `chore/random_order_audit`, 2026-09-10. Companion to `internal/notes/test_suite_parallelism.md`, which covers why processes rather than threads, and to `internal/order_dependent_specs.md`, which is the defect list.

## The numbers

A developer machine with 14 cores, against a macOS runner with 3 and a Linux runner with 4:

| Workers | 14 cores, local | macOS runner, 3 cores | Linux runner, 4 cores |
| --- | --- | --- | --- |
| 1 | 276s | ~562s | ~130s |
| 2 | 140s | 412s | 89s |
| 4 | 75s | **151s** | **71s** |
| 6 | 58s | 266s | |
| 8 | 50s | | |
| 12 | **41s** | | |

Four workers is the knee on both runners. Six on macOS is worse than four, which is a three core runner being asked to run six workers that each drag an `xcodebuild` child along with them.

The single run those first macOS figures came from was not enough to say so with confidence. Across five runs of the same commit:

| Workers | Fastest | Median | Slowest |
| --- | --- | --- | --- |
| 2 | 229 | 337 | 412 |
| 4 | 151 | 243 | 252 |
| 6 | 266 | 303 | 391 |

A runner varies by a factor of nearly two on identical work, so any single measurement from one is close to worthless. Four is reliably the best of the three, and six is reliably the worst, but the earlier statement that six costs 266s against four's 151s was comparing two samples that happen to be the fastest of their groups. The medians, 243s against 303s, are the honest comparison.

Local numbers on a machine that is not shared do not behave this way, and the local table above is from single runs.

`test_parallel` defaults to `min(cores, 12)`, which picks 3 on the macOS runner and 4 on Linux. Three is a little conservative for macOS; four measured better. The cap matters on a large machine, where one worker per core oversubscribes badly.

## Linux is a different suite, not the same one on another runner

7837 examples with 409 pending, against 7863 with none on macOS. Without Xcode the `requires_xcodebuild` and `requires_keychain` specs skip, and those are 61% of the example time.

That has two consequences. Linux is cheap ordering coverage, 130s against 562s, and it says nothing at all about the expensive half of the suite. And parallelism helps it much less: 130s to 71s is 1.8x on four cores, against 3.7x for the same worker count on macOS. What is left after the skips is mostly CPU bound Ruby, so there is less waiting to overlap. The macOS gain comes from subprocesses, which is also why its knee sits where it does.

## Isolated HOME

`rake test_isolated` points `HOME` at a directory the run controls and seeds it with an empty keychain. Its purpose is not speed: it makes a spec that depends on state an earlier run left in `~` fail on the machine that wrote it. Row Z survived for months because every machine that had run the suite already had the file the examples needed, and only a clean CI checkout ever failed.

It costs about 7% locally, 44s against 41s on twelve workers, and that is flat: a second run against the same directory is no faster, so nothing expensive is being cached there.

On the macOS runner it cost considerably more, 242s against 151s at four workers. Three cores have much less headroom than fourteen, and that gap is not yet explained. Worth understanding before making it a default anywhere.

A full run leaves 58 entries in `HOME` and a second run leaves 83, so the suite does not converge on a fixed set. What it writes: `~/.fastlane`, `~/Library/Logs` for four tools, `~/Library/MobileDevice/Provisioning Profiles`, `~/Library/Developer/Xcode`, `~/.appstoreconnect`, a rubocop cache, and certificates in the default keychain as a side effect of `security cms -D` decoding provisioning profiles.

## Cold runners cost nothing

GitHub gives a fresh VM every run, which raises a fair question about caching. The answer here is no: a second isolated run against a warm directory took 45s against the first run's 44s. Nothing expensive is cached in `HOME`, so `actions/cache` on `~/Library/Developer/Xcode` or `~/.cache` would not help. The runners are slower than a developer machine because they have three or four cores against fourteen.

## Suggested configuration

**A developer on macOS**: `WORKERS=8 rake test_parallel`, 276s to 50s. Twelve is slightly faster at 41s but the returns are thin past eight. `rake test_isolated` before pushing anything that touches how specs read the environment or the filesystem.

**macOS CI**: four workers, a median of 243s against 562s sequential. The default of `min(cores, 12)` picks three, which is close; pinning `WORKERS: 4` is worth the two lines.

**Linux CI**: four workers, 130s to 71s. Cheap, and worth keeping for ordering coverage on a suite shape macOS never exercises.

**Not worth doing**: more than four workers on a three core runner, caching the home directory, or one worker per core on a large machine.

## What is still open

The isolated home costing 60% on a runner against 7% locally.

Whether the macOS knee moves once the specs stop shelling out to xcodebuild for build settings. Two attempts at that are written up in `internal/notes/xcodebuild_build_settings.md`, both reverted.

Windows has not been measured at all. `ci.yml` covers it, this audit does not.

## Timings have to come from the platform they balance

The split is packed from recorded per file durations, and there was one file of them for every platform. That is wrong: the suite is a different shape on each, so a Linux split balanced from macOS numbers packs around files that cost nothing there.

Three of the heaviest macOS files are free on Linux, where the `requires_xcodebuild` specs skip:

```
scan/spec/detect_values_spec.rb      mac 32.2s -> linux  0.0s
scan/spec/runner_spec.rb             mac 29.1s -> linux  0.0s
scan/spec/slack_poster_spec.rb       mac 12.2s -> linux  0.0s
fastlane_core/spec/project_spec.rb   mac 35.1s -> linux  4.5s
deliver/spec/upload_metadata_spec.rb mac 27.2s -> linux 27.1s
```

Whole suite: 275s of example time on macOS, 113s on Linux.

What that cost, on the Linux runner at four workers:

| Balanced from | Spread | Idle | Wall clock |
| --- | --- | --- | --- |
| macOS timings | 62% to 73% | 41% to 48% | 58s to 70s |
| Linux timings | 23% | 12% | 43s |

Nearly half the worker time was spent waiting for a straggler, and fixing the input took the wall clock down by a third. At two workers the split goes from 26% to 29% idle to 1%.

This is also why Linux parallelism looked weak earlier in this document, 1.8x against macOS's 3.7x. That was not Linux having less to overlap, it was a split built from the wrong numbers.

Timings now live in `internal/spec_timings.<platform>.json`, and the workflow has a `record_timings` input, `macos`, `linux` or `both`, which runs the suite once in a single process on that runner and uploads the file to be committed. Nobody needs the hardware to fix the balance for a platform they do not have.

`deliver/spec/upload_metadata_spec.rb` is now the thing to look at on Linux: 27.1s of a 113s suite, 24% of it, and identical on both platforms. Four workers cannot go below it however well balanced, which is most of the 12% that remains.

### Cutting files up more aggressively does not help, at least not where it was measured

`SPLIT_THRESHOLD` decides when a file is heavy enough to be cut into runs of examples: at 1.05 it has to exceed a whole worker's share. Lowering it was worth trying, because a file at 0.96 of a share is just as bad as one at 1.05 and is not caught.

Measured on 14 cores, three thresholds at two worker counts:

| Threshold | 4 workers | 8 workers |
| --- | --- | --- |
| 1.05 | 77s, spread 2%, idle 1% | 49s, spread 19%, idle 7% |
| 0.5 | 76s, spread 1%, idle 1% | 50s, spread 19%, idle 6% |
| 0.33 | 76s, spread 1%, idle 0% | 48s, spread 17%, idle 8% |

All within noise, so the default stays at 1.05. It is overridable through the environment for anyone who wants to measure it on their own hardware.

The measurement has a hole in it worth stating. The case that prompted it is Linux at four workers, where `upload_metadata_spec` is 96% of a share. On 14 cores with 275s of work that situation does not arise: at four workers the split is already at 2% spread and 1% idle, because each share is large next to the biggest file. So these numbers show the change is harmless where it is not needed, and say nothing about whether it helps where it is. Testing that needs `SPLIT_THRESHOLD` plumbed through the workflow.

The related finding is that imbalance is a function of worker count rather than a standing property of the split. The 42% spread recorded earlier was at twelve workers, not four.
