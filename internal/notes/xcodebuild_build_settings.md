# Making the specs stop running xcodebuild so often

Two attempts, both reverted, and what is left to try. Written 2026-09-10 against `chore/random_order_audit`. See fastlane#30184.

## The prize

About 180 examples ask a fixture project for its build settings, and each one runs `xcodebuild -showBuildSettings` for real at roughly a second a time. They are not 180 different questions: the whole suite only ever asks about seven fixture projects, so it is the same 22 commands over and over.

`FastlaneCore::Project#build_settings` already memoises the answer on `@build_settings`, but per instance, and every example builds a fresh `Project`, so nothing is ever reused.

The share is about 70s of the 276s sequential run, so roughly 25%.

It matters twice over. It is a quarter of the wall clock everyone pays, and each of those examples is a worker *plus* an xcodebuild child waiting on it, so removing them cuts the effective process count and lets the parallel worker count rise. Both attempts below improved the parallel curve as well as the sequential one.

Two estimates made earlier were both too high and are worth correcting, because they were arrived at by measuring the wrong thing:

- "61% of example time is in `requires_xcodebuild` files" is true but those files also query simulators, run `xcodebuild -list` and sleep on purpose.
- "the suite runs in 117s with `FASTLANE_DISALLOW_XCODEBUILD_SETTINGS_LOOKUP` set" is true but 233 examples then fail fast and skip the rest of their work.

## Where to intercept

`fastlane_core/lib/fastlane_core/project.rb:452`:

```ruby
@build_settings = FastlaneCore::Project.run_command(command, timeout: timeout, retries: retries, print: true)
```

`run_command` is a class method, so a spec helper can wrap it without touching production code or any spec file. That matters: five open pull requests sit on the files a call-site rewrite would have touched, #22069 directly on `project.rb`.

Only `-showBuildSettings` may be intercepted. `fastlane_core/spec/project_spec.rb:453` tests `run_command` itself with `echo` and with deliberate timeouts, and those have to keep shelling out.

## Attempt 1, recorded fixtures. Tried and reverted

Record each command's output to `fastlane_core/spec/fixtures/xcodebuild_settings` and replay it, refreshing with `RECORD_XCODEBUILD_SETTINGS=1`. 22 files, 768K.

| | Baseline | Recorded |
| --- | --- | --- |
| Sequential | 276s | 210s |
| 4 workers | 75s | 58s |
| 12 workers | 49s | 36s |

It broke every CI job.

Build settings carry the machine all the way through them. In one 548 line output: 60 references to the checkout path, 64 to the home directory, 45 to `/Applications/Xcode-26.3.0.app`. The runner has a different checkout path and Xcode 16.4. `scan/spec/detect_values_spec.rb:48` failed loudly by comparing a derived data path against the local checkout, which was the lucky part: most of a recorded file would have been *silently* wrong on a machine with a different Xcode, since SDK paths, toolchains and deployment targets are all in there.

Normalising the checkout path and the home directory is easy. Normalising the Xcode version is not, because the settings genuinely differ between versions. A recorded fixture would have to be keyed by Xcode version and regenerated for each, which is more machinery than the 25% is worth.

## Attempt 2, memoise for the length of the run. Tried and reverted

Hold the answers in a hash for the process lifetime, keyed by command. The first example to ask computes, the rest read. Nothing persisted, nothing machine specific, computed on the machine that is asking.

| | Baseline | Memoised |
| --- | --- | --- |
| Sequential | 276s | 223s |
| 4 workers | 75s | 63s |
| 12 workers | 49s | 41s |

Slightly behind the recorded version because each worker pays its own first call. It also broke CI, for a different reason.

`scan/spec/detect_values_spec.rb:41` copies a `WorkspaceSettings.xcsettings` **into the fixture project**:

```ruby
FileUtils.copy("./scan/examples/standard/WorkspaceSettings.xcsettings",
               "./scan/examples/standard/app.xcodeproj/project.xcworkspace/xcuserdata/#{ENV['USER']}.xcuserdatad/WorkspaceSettings.xcsettings")
```

That file redirects DerivedData, so the identical command returns different output depending on whether it exists. Keying on the command alone replays an answer computed before the copy.

The command string is not a sufficient key. The output depends on the state of the project directory as well.

## Why neither was caught locally

Both attempts passed here and failed on the runner, and in both cases local testing was structurally incapable of finding the problem.

The recorded fixtures were written on this machine and replayed on this machine, so the embedded paths matched by construction. The check that would have falsified it is replaying fixtures recorded somewhere else, and nothing local does that.

The memoisation was checked against three random seeds precisely because the hazard was known to be a spec mutating a fixture project. They all passed, because that `WorkspaceSettings.xcsettings` already exists in this working copy, left by earlier runs. It is untracked. CI checks out fresh.

That is the same shape as three other defects found on this branch: a spec reading the harness's own log file as a screenshot fixture, a stale generated `.rubocop.yml`, and a spaceship cookie nine months older than the run depending on it. A working copy accumulates state that a runner never has, so a green local run is weaker evidence than it looks.

Anything attempted here again should be verified in a clean checkout. `git clean -dn` lists what this tree carries that a runner's does not, and on the machine this was written on that is 106 entries, 45 of them inside `spec/` or `examples/` directories:

```
scan/examples/standard/app.xcodeproj/project.xcworkspace/xcuserdata/<user>.xcuserdatad/WorkspaceSettings.xcsettings
fastlane_core/spec/fixtures/projects/Example.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/
gym/examples/*/[...]/project.xcworkspace/xcshareddata/swiftpm/
fastlane/spec/fixtures/plugins/ImportFromGem/Gemfile.lock
...
```

The first of those is the file that broke attempt 2. The rest are the same hazard waiting for a different change to trip over: every one is an input some spec may read, present here and absent on a runner.

Most are written by the suite itself. Xcode creates `xcshareddata/swiftpm` when it opens a project, `bundle install` writes the plugin lockfiles, and `detect_values_spec` copies the workspace settings in deliberately. None of them are cleaned up.

**Checks worth adding, on CI only.** A developer's working copy legitimately accumulates things and a clean tree cannot be required of it. A runner starts from a fresh checkout, so anything present after a run was put there by the run.

The obvious form of that, `git status --porcelain` after the suite, would have caught none of the four leftovers found on this branch, which is worth knowing before anyone builds it:

| Left behind | Where | Seen by `git status --porcelain` |
| --- | --- | --- |
| `WorkspaceSettings.xcsettings` | in the repo, under `xcuserdata/` | no, `.gitignore:77` ignores it |
| template `.rubocop.yml` | in the repo | no, explicitly ignored at `.gitignore:60` |
| `#{Dir.tmpdir}/fastlane_tests` | outside the repo | no |
| `~/.fastlane/spaceship/<user>/cookie` | outside the repo | no |

It does show eight untracked fixture entries, which are worth cleaning up, but the defects were all somewhere it does not look. Two checks that would work:

- `git status --porcelain --ignored` on CI, against a baseline taken before the run. Catches the first two. Noisy without a baseline, since `vendor/` and friends are ignored too.
- Run the suite on CI with `HOME` pointed at a fresh temporary directory. Catches the last two, and more usefully makes a spec that depends on pre-existing home state fail on the runner rather than passing everywhere except a colleague's laptop. The spaceship cookie is exactly that: row Z passed for months on any machine that had ever run the suite.

## What is left to try

**Key the cache on the project's state as well as the command.** The maximum mtime under the `.xcodeproj` would do it: a spec writing into the project changes the key and forces a recompute. Principled, handles the known failure, and cheap for directories this size. It does not cover inputs that are neither in the command nor in the project directory, and nobody has enumerated those.

**Stop the specs mutating shared fixture projects.** `detect_values_spec` could copy the project to a temporary directory and work there. That removes the hazard rather than working around it, and would help the parallel split too, where several workers share one checkout. It touches files with open pull requests, so it wants coordinating.

**Narrow the memo to a group.** Safe where a group asks the same question repeatedly, worth much less, and needs each group opted in by hand.

**Leave it.** The parallel work alone took the suite from 276s to 41s on twelve workers. The 25% is real but it has now cost two red CI runs, and it is the smaller half of what has already been won.

## Running against a home directory the project controls

`rake test_isolated` points `HOME` at a throwaway directory, seeds it with an empty keychain, runs the suite and then reports what the run wrote there. `WORKERS=12 rake test_isolated` splits it; a pattern argument runs a subset.

It exists because the suite both reads and writes the developer's real home, and reading is the dangerous half. Row Z is the example: `Client#itc_service_key` cached to a file, the examples depending on that file passed on any machine that had ever run the suite, and only a clean CI checkout failed. An isolated home makes that fail here instead.

The writing half is not small either. A full run leaves 53 entries in `HOME`:

```
~/.fastlane/.did_show_opt_info
~/Library/Developer/Xcode/Archives
~/Library/MobileDevice/Provisioning Profiles
~/Library/Logs/{fastlane,gym,scan,snapshot}
~/.appstoreconnect
~/.cache/rubocop_cache
```

Unseeded, nine examples fail, seven in `verify_build_spec` and two in `match/spec/importer_spec`, all with a keychain complaint. The obvious reading is that those specs reach into the developer's keychain and should be stubbed. That is not what is happening, and it is worth recording so nobody stubs them:

```
security cms -D   real home                  exit 0
                  isolated home, no keychain exit 1, "cert import failed: A default keychain could not be found"
                  isolated home, EMPTY one   exit 0
```

Nothing calls `security import`. `security cms -D`, which fastlane uses to decode provisioning profiles in `verify_build.rb`, `provisioning_profile.rb` and sigh's `local_manage.rb`, imports the signing certificate in order to verify the signature. Any keychain will do, including an empty one, and the certificates it writes are a side effect of decoding rather than anything the specs asked for. A full run puts four of them in the default keychain, three from the two match examples and one from verify_build.

So the specs are doing legitimate work and stubbing them would remove real coverage. Seeding a keychain in the isolated home is the fix: the certificates land in a directory that is deleted afterwards rather than in the developer's login keychain.

Worth raising separately: this is production behaviour, not a test artefact. fastlane adds certificates to a user's keychain whenever it parses a provisioning profile. `provisioning_profile.rb` already has a `-k <keychain_path>` variant of the call, so there is a mechanism for directing it somewhere chosen.

### What isolation costs, measured

Twelve workers, same machine:

| | Wall clock |
| --- | --- |
| Real home, warm | 41s |
| Isolated home, first run | 44s |
| Isolated home, second run against the same directory | 45s |
| Isolated home, no keychain seeded | 244s, three workers failing |

About 7%, and flat. The second run is not faster than the first, so nothing expensive is being cached in `HOME` and there is no warm-up to amortise.

The 244s is worth explaining because it was briefly reported here as the cost of isolation, and it is not. Without a seeded keychain `security` puts up a modal asking for keychain access and waits for it to be answered, so on a machine with a desktop session the run stalls rather than failing. Twelve workers hitting that is what turned 44s into 244s.

Unattended it behaves differently, and better. With no session to draw on, `security` returns exit 36 with empty output instead of prompting. That was established while reproducing fastlane-community/security#5, over `ssh localhost` with `SSH_TTY` empty and `launchctl managername` reporting `Background`. So CI would not stall here, it would fail, and this guard is for the developer running it locally rather than for the runner.

`rake test_isolated` checks the keychain exists before running anything and refuses to start otherwise.

Two things follow.

Isolation is cheap enough to be the default way to run the suite rather than an occasional check, which is what would make a spec depending on leftover home state fail on the machine that wrote it.

And GitHub's runners being cold on every run costs nothing here, since warm and cold are the same. Caching `~/Library/Developer/Xcode` or `~/.cache` would not speed CI up. CI is slower than this machine because it has three or four cores against fourteen, not because it starts empty.

One more observation from the same measurement: the isolated home held 58 entries after the first run and 83 after the second. The suite does not converge on a fixed set, it keeps adding.
