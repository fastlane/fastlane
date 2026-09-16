# When a spec passes alone and fails in the split

_fastlane_'s suite runs as several independent rspec processes (`rake test_parallel`), which is what CI runs. A worker gets a subset of the files in an order no seed produces, and several workers run at once on one machine.

That breaks specs in ways a sequential run never does. This is a catalogue of the classes we actually hit while making the suite parallel, what each looks like from the outside, and how it was fixed. Every entry has a real change behind it.

See [Testing.md](Testing.md) for the commands.

## First: which kind of failure is it?

Two questions separate almost every case.

**Does it fail on its own?** Take the failing example and run just it:

```
bundle exec rspec ./path/to/some_spec.rb:42
```

If it fails alone, it is a plain bug and none of this applies. If it passes alone, something else is involved.

**Does it fail from the same file list, in one process?** The split is reproducible: a failed worker prints the file that lists what it ran.

```
rspec $(cat rspec_worker_2.units)
```

- **Fails here too** — the cause is *order*: something in that file list runs before your spec and changes what it sees. Sections 1, 5 and 10 below.
- **Passes here, failed on CI** — the cause is *concurrency* or *environment*: another worker was touching the same thing at the same time, or the machine differed. Sections 2, 3, 4, 6, 7, 8, 9.

That second case is the one worth being careful about: a green rerun is not evidence the bug is gone, only that the timing did not line up. To raise your confidence, run the two suspect files against each other repeatedly rather than rerunning the whole suite — a race that fires one run in twenty shows up in a few minutes that way and not at all in a rerun.

## 1. Order dependence

**Looks like**: passes alone and in a full sequential run, fails in a worker. Often an empty collection, a `nil`, or a login that never happened.

**Why**: the example relies on another example having run first — populating a cache, logging a client in, creating a file.

**Fix**: give the example everything it needs. A `before` hook that sets up its own state, not an assumption about what came before.

**Note**: this is the one class a random order finds cheaply. `RSPEC_ARGS="--order random" bundle exec rake test_parallel` before you push is worth the minute.

## 2. Fixed paths under the temporary directory

**Looks like**: intermittent `ENOENT`, `EEXIST`, or a file whose contents are not what the example just wrote.

**Why**: two workers using the same literal path. `/tmp/fastlane/something`, or `"#{Dir.tmpdir}/some_fixed_name"` — `Dir.tmpdir` is a *shared root*, not a private directory.

**Fix**: `Dir.mktmpdir`, which is unique per call, or the suite's own scratch root `FASTLANE_SPEC_SCRATCH` (`spec_helper.rb:31`). Never a fixed basename under `Dir.tmpdir`.

**Landed as**: #30217, #30220, #30225.

## 3. The working directory

**Looks like**: a path that resolves somewhere unexpected, or `EACCES` on Windows in a spec that never touches permissions.

**Why**: `Dir.chdir` is a *process-wide* syscall. Within one worker, a spec that chdirs and fails to restore leaves every later example in the wrong place. Ruby also refuses concurrent use outright inside one process: `RuntimeError: conflicting chdir during another chdir block`.

**Fix**: restore it structurally rather than in an `after` hook, so an exception cannot skip the restore:

```ruby
around do |example|
  Dir.mktmpdir { |dir| Dir.chdir(dir) { example.run } }
end
```

**Landed as**: #30221.

## 4. Environment variables

**Looks like**: a spec reads a credential or a flag it never set, and behaves differently depending on what ran before it.

**Why**: `ENV` is process-global. A spec that assigns to it leaks into every later example in that worker.

**Fix**: `FastlaneSpec::Env.with_env_values`, or declare the variable as a deliberate output:

```ruby
it "sets the team id", env_output: %w[FASTLANE_TEAM_ID] do
```

**Already guarded**: the env guard restores `ENV` after every example and fails on an undeclared escape. `FASTLANE_SPEC_ENV_GUARD=report` to see leaks without enforcing, `=off` to disable.

## 5. Module-level singletons

**Looks like**: a tool reads configuration that this example never provided.

**Why**: fastlane's tools keep configuration in module-level state (`Fastlane::Actions.lane_context`, `FastlaneCore::Globals`, each tool's `.config`). It survives between examples.

**Fix**: set what you need; do not inherit it.

**Already guarded**: the singleton guard resets that state after each example. `FASTLANE_SPEC_SINGLETON_GUARD=off` to disable.

## 6. State in the home directory

**Looks like**: passes for everyone who has run the suite before, fails on a clean checkout or a new contributor's machine. The hardest class to notice, because the person who wrote it cannot reproduce it.

**Why**: the suite both writes and *reads* `$HOME` — caches, logs, provisioning profiles, keychains. An example that depends on a file an earlier run left there passes on any machine that has ever run the suite.

**Fix**: do not read from `$HOME` unless that is what is under test; stub the lookup.

**Find it with**: `bundle exec rake test_isolated`, which points `HOME` and `TMPDIR` at throwaway directories and reports what the run wrote into them.

**Landed as**: #30195.

## 7. Machine-global resources outside the process

**Looks like**: fails only when the suite is run in parallel, on any machine, and the failing assertion is about something the operating system owns.

**Why**: some resources are singular per machine and no amount of process isolation helps. The system clipboard. The default keychain. A fixed network port.

**Fix**: stub at the boundary. These cannot be partitioned between workers.

**Landed as**: #30211 (clipboard).

**Still open**: the keychain. Parts of the suite still import certificates into the real login keychain, and every worker shares it.

## 8. Object lifetime and the garbage collector

**Looks like**: a file that existed a moment ago is gone, intermittently, with no code deleting it.

**Why**: `Tempfile` unlinks its file when the object is collected. Keeping only the path drops the last reference:

```ruby
path = Tempfile.new("x").path   # the file may vanish at any GC
```

Parallelism changes memory pressure, so it changes when GC runs — which is why this surfaces under a split and not before.

**Fix**: keep the object alive for as long as the file is needed.

**Landed as**: #30227.

## 9. Platform assumptions

**Looks like**: green on macOS and Linux, fails on Windows, in a spec that has nothing to do with platforms.

**Why**: a hardcoded POSIX path. `/tmp` is `C:/tmp` on Windows and does not exist by default. These often hide behind a side effect — one spec's `mkdir_p('/tmp/fastlane')` was creating the directory that three unrelated specs then relied on.

**Fix**: `Dir.tmpdir`, `File.join`, `Dir.mktmpdir`. Never a literal separator or root.

**Landed as**: #30220.

## 10. Fixtures mutated in place

**Looks like**: one spec fails depending on whether another has run, and the assertion is about file contents.

**Why**: a spec writes to a checked-in fixture that another spec reads. In one process the damage is ordered; across workers it is a race on a file in the repository.

**Fix**: copy the fixture into a scratch directory and modify the copy.

**Landed as**: #30215.

## Writing a spec that will not break

Most of this reduces to a short list.

- Everything the example needs, the example sets up.
- Every path it writes to is unique to that example: `Dir.mktmpdir` or `FASTLANE_SPEC_SCRATCH`.
- Every process-wide thing it changes is restored structurally, in an `around` or a block form, not in an `after`.
- Nothing outside the process is touched for real — clipboard, keychain, network, the user's home.
- It does not care what ran before it, and leaves nothing that would matter to what runs after.

## Before pushing

```
RSPEC_ARGS="--order random" bundle exec rake test_parallel
```

The split and a random order find different things: the split gives a subset no seed produces, the seed shuffles what is inside it. Together they are most of what CI can tell you, several minutes earlier.
