# What to run, where, and with how many workers

Measured 2026-09-10, and again on the runners when the timings were first recorded. Worker counts and workflow inputs rechecked against master 2026-09-16. Companion to `test_suite_parallelism.md`, which covers why processes rather than threads. The defects this work depended on are fastlane#30184.

## The numbers

Every figure in this note came off specific hardware, and none of it generalises on its own. One developer machine with 14 cores; GitHub's hosted runners as they were in September 2026, reporting 3 cores on macOS and 4 on Linux and Windows. A different core count, a different Xcode, or a runner generation change moves all of it. Treat the shape of the curves as the finding and the absolute numbers as illustrations; `rake test_tune` is how you get numbers for a machine that is not one of these.

A developer machine with 14 cores, against a macOS runner with 3 and a Linux runner with 4:

| Workers | 14 cores, local | macOS runner, 3 cores | Linux runner, 4 cores |
| --- | --- | --- | --- |
| 1 | 276s | ~562s | ~130s |
| 2 | 140s | 412s | 89s |
| 4 | 75s | **151s** | **71s** |
| 6 | 58s | 266s | |
| 8 | 50s | | |
| 12 | **41s** | | |

Four workers is the knee on both runners. Six on macOS is worse than four, which is a three core runner being asked to run six workers that each drag an `xcodebuild` child along with them. The macOS column is single runs and the 151s in it is a lucky one; the five sample table below is the honest version, and 151s should not be quoted on its own.

The single run those first macOS figures came from was not enough to say so with confidence. Across five runs of the same commit:

| Workers | Fastest | Median | Slowest |
| --- | --- | --- | --- |
| 2 | 229 | 337 | 412 |
| 4 | 151 | 243 | 252 |
| 6 | 266 | 303 | 391 |

A runner varies by a factor of nearly two on identical work, so any single measurement from one is close to worthless. Four is reliably the best of the three, and six is reliably the worst, but the earlier statement that six costs 266s against four's 151s was comparing two samples that happen to be the fastest of their groups. The medians, 243s against 303s, are the honest comparison.

Local numbers on a machine that is not shared do not behave this way, and the local table above is from single runs.

`test_parallel` defaults to `min(cores, 8)`. CI pins `WORKERS: 4` in `.github/workflows/ci.yml`, which is what all three runners use; they report 3 cores on macOS and 4 on Linux and Windows. The cap matters on a large machine, where one worker per core oversubscribes badly.

## Linux is a different suite, not the same one on another runner

7837 examples with 409 pending, against 7863 with none on macOS. Without Xcode the `requires_xcodebuild` and `requires_keychain` specs skip, and those are 61% of the example time.

That has two consequences. Linux is cheap ordering coverage, 130s against 562s, and it says nothing at all about the expensive half of the suite. And parallelism helps it much less: 130s to 71s is 1.8x on four cores, against 3.7x for the same worker count on macOS. What is left after the skips is mostly CPU bound Ruby, so there is less waiting to overlap. The macOS gain comes from subprocesses, which is also why its knee sits where it does.

## Isolated HOME

`rake test_isolated` points `HOME` and `TMPDIR` at throwaway directories, seeds an empty keychain, runs the suite and reports what the run wrote there. `WORKERS=12 rake test_isolated` splits it; a pattern argument runs a subset.

Its purpose is not speed. The suite both reads and writes the developer's home, and reading is the dangerous half: Row Z is the example, `Client#itc_service_key` cached to a file, and the examples depending on that file passed on any machine that had ever run the suite. Only a clean CI checkout failed. An isolated home makes that fail on the machine that wrote it.

The writing half is not small either. What it writes:

```
~/.fastlane/.did_show_opt_info
~/Library/Developer/Xcode/Archives
~/Library/MobileDevice/Provisioning Profiles
~/Library/Logs/{fastlane,gym,scan,snapshot}
~/.appstoreconnect
~/.cache/rubocop_cache
```

### The keychain failures are not specs reaching into your keychain

Unseeded, nine examples fail, seven in `verify_build_spec` and two in `match/spec/importer_spec`, all with a keychain complaint. The obvious reading is that those specs should be stubbed. That is not what is happening, and it is worth recording so nobody stubs them:

```
security cms -D   real home                  exit 0
                  isolated home, no keychain exit 1, "cert import failed: A default keychain could not be found"
                  isolated home, EMPTY one   exit 0
```

Nothing calls `security import`. `security cms -D`, which fastlane uses to decode provisioning profiles in `verify_build.rb`, `provisioning_profile.rb` and sigh's `local_manage.rb`, imports the signing certificate in order to verify the signature. Any keychain will do, including an empty one, and the certificates it writes are a side effect of decoding rather than anything the specs asked for. A full run puts four of them in the default keychain, three from the two match examples and one from verify_build.

So the specs are doing legitimate work and stubbing them would remove real coverage. Seeding a keychain in the isolated home is the fix: the certificates land in a directory that is deleted afterwards rather than in the developer's login keychain.

Worth raising separately: this is production behaviour, not a test artefact. fastlane adds certificates to a user's keychain whenever it parses a provisioning profile. `provisioning_profile.rb` already has a `-k <keychain_path>` variant of the call, so there is a mechanism for directing it somewhere chosen.

### What isolation costs, measured

Two separate questions get confused here, so to be explicit. *Isolated against real* asks what redirecting `HOME` costs. *Cold against warm* asks whether a `HOME` that has already been written to makes a later run faster. The answers are about 7% and nothing.

Twelve workers, on the developer machine:

| | Wall clock |
| --- | --- |
| Real home, warm | 41s |
| Isolated home, first run | 44s |
| Isolated home, second run against the same directory | 45s |
| Isolated home, no keychain seeded | 244s, three workers failing |

About 7%, and flat. The second run is not faster than the first, so nothing expensive is being cached in `HOME` and there is no warm-up to amortise.

The 244s is worth explaining because it was briefly reported as the cost of isolation, and it is not. Without a seeded keychain `security` puts up a modal asking for keychain access and waits for it to be answered, so on a machine with a desktop session the run stalls rather than failing. Twelve workers hitting that is what turned 44s into 244s.

Unattended it behaves differently, and better. With no session to draw on, `security` returns exit 36 with empty output instead of prompting. That was established while reproducing fastlane-community/security#5, over `ssh localhost` with `SSH_TTY` empty and `launchctl managername` reporting `Background`. So CI would not stall here, it would fail, and this guard is for the developer running it locally rather than for the runner. `rake test_isolated` checks the keychain exists before running anything and refuses to start otherwise.

On the macOS runner an isolated run took 242s at four workers. That was once written up here as isolation costing 60% on a runner, against 151s for the real home, and that comparison was wrong: 151s is the *fastest* of the five real-home samples under **The numbers** at the top of this note, whose median is 243s. Against the median, 242s against 243s, isolation costs nothing measurable there.

It is the mistake this note warns about two sections above — a runner varies by nearly a factor of two on identical work, so a single sample is close to worthless — made before the warning was written and not revisited afterwards. One isolated sample is no better, so the honest statement is that isolation has not been shown to cost anything on the runner, not that it has been shown to be free.

The isolated home held 58 entries after the first run and 83 after the second. The suite does not converge on a fixed set, it keeps adding.

### Cold runners cost nothing

Warm and cold are the same, so GitHub giving a fresh VM every run costs nothing: the second isolated run against a warm directory took 45s against the first run's 44s. `actions/cache` on `~/Library/Developer/Xcode` or `~/.cache` would not help. The runners are slower than a developer machine because they have three or four cores against fourteen, not because they start empty.

## What the numbers come out at

Testing.md covers the commands; these are the conclusions behind them, and they are conclusions about the hardware listed at the top of this note rather than about the suite in the abstract.

**CI**: four workers on every runner, pinned in `ci.yml`. A median of 243s on macOS against a single sequential sample of ~562s, and 130s to 71s on Linux. The `min(cores, 8)` default would pick three on the macOS runners; three was never measured, so pinning four is a choice between a measured number and an unmeasured one rather than a demonstrated improvement.

**A developer**: eight workers on a fourteen core machine, 276s to 50s. Twelve is slightly faster at 41s and the returns past eight are thin. `rake test_tune` measures it on your own hardware, which is the honest answer for a machine nobody here has seen.

**Not worth doing**: more than four workers on a three core runner, caching the home directory, or one worker per core on a large machine.

## What is still open

Whether the macOS knee moves once the specs stop shelling out to xcodebuild for build settings. Two attempts at that are written up in `internal/notes/xcodebuild_build_settings.md`, both reverted.

~~Windows has not been measured at all.~~ Since measured: the split runs there too, and it is a third shape again. Its whole suite is 283s against 558s on macOS and 106s on Linux, and its heaviest files are gradle and the crashlytics upload, neither of which is near the top anywhere else. Adding it found three defects that no seed had produced, all of them a literal `/tmp` that does not exist on that platform.

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

Timings now live in `internal/spec_timings.<platform>.json`, and the workflow has a `record_timings` input, `macos`, `linux`, `windows` or `all`, which runs the suite once in a single process on that runner and uploads the file to be committed. Nobody needs the hardware to fix the balance for a platform they do not have.

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
