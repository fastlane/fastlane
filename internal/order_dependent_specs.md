# Order dependent specs

The suite passes in the order rspec happens to load files in, and fails in others. See fastlane#30184. This file is the working list, and it is also the input to `rake test_order_dependent`, so the table and the list below it stay in step.

Counts come from two runs at the time of writing: CI on `chore/random_order_audit` at seed 48174 (7847 examples, 48 failures), and the same seed locally on macOS with Ruby 4.0.5 (39 failures). A row failing in one and not the other is not noise to be ignored, it is a hint about what the failure depends on.

Entries stay in the list until the whole suite is stable, not until their own row closes. A file that has just been fixed is exactly the one worth re-running in new orderings.

Why this is being done, and what it unblocks, is in `internal/notes/test_suite_parallelism.md`.

| Row | CI | Local | Files | Symptom | Likely cause | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A | 16 | 1 | `spaceship/spec/spaceship_spec.rb` (10), `spaceauth_spec.rb` (6) | `WebMock::NetConnectNotAllowedError` on `POST https://idmsa.apple.com/appleauth/auth/signin/init` | A login ran without the SIRP stub, so a real SRP value was computed and matched none of the recorded request bodies | **fixed** in `b63ab357a`, confirmed at seed 48174: all 16 gone, no `signin/init` request blocked anywhere in the run |
| B | 15 | 15 | `connect_api/models/`: `device_spec.rb` (8), `certificate_spec.rb` (3), `build_beta_detail_spec.rb`, `beta_build_metric_spec.rb`, `app_store_version_release_request_spec.rb`, `build_delivery_spec.rb` | `TypeError: You need to instantiate this module with provisioning_request_client`, also `test_flight_request_client` and `tunes_request_client` | ConnectAPI sub-clients are module level state that an earlier example instantiates and later ones inherit | **fixed**, confirmed locally at seed 48174: 39 to 24, exactly these 15, nothing new |
| C | 5 | 5 | `frameit/spec/editor_spec.rb` | `undefined method '[]' for nil` at `frameit/lib/frameit/screenshot.rb:45` | `Frameit.config` is module level state, normally set by the commands generator. `editor_spec` only sets it in the `frame!` group, so the `should_skip?` and `fetch_text` groups relied on an earlier example leaving one behind | **fixed**, confirmed locally at seed 48174: 24 to 19, exactly these 5, nothing new |
| D | 4 | 4 | `fastlane/spec/actions_specs/import_from_git_spec.rb` | `FastlaneCore::UI received :important with unexpected arguments`, `expected: 0 times with arguments: (/git checkout/)` | Not a leaked global. The group is one scenario written as several examples: a `before :all` builds a git repository and individual examples append commits, tags and branches that later ones assert on. A random order makes them assert against the wrong revision | **fixed** by pinning the group with `order: :defined`, 17 to 13 |
| E | 2 | 2 | `fastlane_core/spec/command_executor_spec.rb` | `Exit status: 42` for commands that cannot fail | Two unrelated causes sharing a count. The examples mocked `Process.wait`, which is what fills in `$?`, while `FastlanePty` reads `$?` for the exit status, so they reported the previous example's status | **fixed** by letting the mocks reap for real. The file now passes on all of seeds 1 to 8 |
| G | 5 | 5 | `fastlane_core/spec/device_manager_spec.rb`, `fastlane/spec/actions_specs/notification_spec.rb`, `fastlane/spec/actions_specs/automatic_code_signing_spec.rb`, `spaceship/spec/two_step_or_factor_client_spec.rb`, `supply/spec/uploader_spec.rb` | assorted | Singles, triaged individually. The supply one looks like a genuine test bug rather than ordering: it calls `all_languages`, which is private | open |
| H | 1 | 1 | `spaceship/spec/portal/portal_permission_spec.rb` | | Not a regression after all. `spaceship_spec.rb` stamps a client onto model classes through `set_client`, and this spec then reads it instead of the one its own login produced. It only surfaced once row A stopped `spaceship_spec.rb` failing early, so the leak had always been there | **fixed** with row I, 19 to 17 |
| J | 1 | 1 | `fastlane_core/spec/command_executor_spec.rb` | `expected "log\n", got "Logging disabled while running tests...\nlog\n"` | Two more causes in the same file. A one shot banner, printed the first time logging is touched in the process, absorbed by whichever example runs first. And `NameError: uninitialized constant PTY`, because FastlanePty requires pty lazily, so examples referencing the constant depended on something else having run a pty backed command first | **fixed**: emit the banner at spec helper load, and require pty in the spec |
| I | 2 | 0 | `spaceship/spec/portal/certificate_spec.rb` | `WebMock::NetConnectNotAllowedError` on `POST .../certificate/submitCertificateRequest.action` | Same leaked client as row H: the request went out through a client from an earlier example, so the stubs this spec registered did not apply | **fixed** with row H |

### Update, pinned run at seed 48174

48 failures before, 33 after, on the same seed. The 16 that went are exactly rows A and F, both in `spaceship_spec.rb` and `spaceauth_spec.rb`. Row F turned out to be the same cause rather than a separate one, so it has been folded into A rather than kept as its own row: the `expected: 0` assertions were downstream of the same failed login.

One failure appeared that was not there before, `portal/portal_permission_spec.rb`, which had only ever failed locally. It arrived in the same run as the fix, so it is recorded as a suspected regression rather than a coincidence.

Row I is confirmed independent of A. The one remaining blocked request is certificate submission, with all three clients live.

### Earlier update, run at seed 58148

Moving the SIRP stubbing to every spaceship example (commit `b63ab357a`) appears to have cleared row A: that run blocked no `signin/init` request at all. Two blocked requests remained in `portal/certificate_spec.rb`, and the diagnostics showed them to be certificate submission rather than login, which is now row I.

That run also totalled 62 failures against 48 at seed 48174. The seeds differ, so the two are not comparable, and 48 was a lower bound as expected. The full job now pins seed 48174 so successive runs measure the same thing; the subset job deliberately does not, so it keeps sampling new orderings.

The diagnostics were wrong in their first form and reported `SRP value was the stubbed one: false` for a request that was not a login at all. The constant is hex and the request body carries its base64, so the comparison could never be true. Fixed to compare the base64 and to only make the claim for `signin/init` requests.

A and B were 30 of the 48 and share a cause: module level singletons in spaceship outliving the example that created them. The obvious remedy does not work. Adding an `after(:each)` that nils `Spaceship::Tunes.client`, `Portal.client` and `ConnectAPI.client` took `spaceship/spec` from 10 failures to 13 on a fixed seed, so some specs rely on the client persisting.

### Row B, how it was found

Two attempts failed first, both leaving the count at 39 with an identical failure set.

1. Calling `Spaceship::ConnectAPI.client` in the `common spaceship login` before hook, so that constructing a client sets the module ivars. No effect.
2. Adding `Spaceship::Portal.login` alongside it. Also no effect.

The reason the first attempt could not have worked is worth keeping. `ConnectAPI::Client#set_individual_clients` only assigns the provisioning client behind a guard:

```ruby
if cookie || token || portal_client
  self.provisioning_request_client = ...
```

`common spaceship login` logs into tunes only, so the implicit client is built with `portal_client: nil` and that branch never runs. The same guard shape applies to `tunes_request_client` and `test_flight_request_client`, which is consistent with all three appearing in the failures.

What resolved it was reading `Spaceship::ConnectAPI.client`:

```ruby
def client
  return @client if @client        # class level, survives the example that set it
  ...
  implicit_client = ConnectAPI::Client.new(tunes_client: ..., portal_client: ...)
  return implicit_client           # never memoised, rebuilt on every call
end
```

`Spaceship::ConnectAPI` forwards its API methods to whatever that returns, and each client extends the API modules onto itself, so the request clients live on the client instance rather than on the module. Two things therefore decide whether a call works, and both are global. A `@client` set by an earlier example wins outright, whatever this example logged into. Absent that, an implicit client is built from the current tunes and portal clients, and only wires up `provisioning_request_client` when a cookie, token or portal client is present.

That is why neither attempt alone moved the count: touching `.client` built a client and discarded it, and adding the portal login did nothing while a stale `@client` was still being returned. Clearing `@client` and logging into the portal together took the run from 39 failures to 24, removing exactly the 15 in this row and adding none.

### Rows H and I, one cause

`Spaceship::Base` subclasses each hold their own `@client`, stamped on by `set_client` and preferred over `Spaceship::Portal.client`:

```ruby
def client
  @client or Spaceship::Portal.client or raise "Please login using ..."
end
```

Class level ivars are not inherited, so clearing `PortalBase`'s does nothing for `Spaceship::Certificate`, which is what `method_missing` stamps when a spec calls `Spaceship.certificate`. An example that logs in afresh still gets answered by the client a previous example left on the model class, which is why the error read `User  (Team ID ...)` with an empty user, and why a request went out unstubbed.

Clearing `@client` across the whole `Spaceship::Base` descendant tree in `before_each_spaceship` fixed both rows at once.

Neither was a regression from the row A fix, though H was recorded as a suspected one at the time. Both leaks predated it and were masked because `spaceship_spec.rb` used to fail early on row A and never reached the code that stamps the client. Expect more of this: each fix lets later examples run further, which can expose the next leak.

### Row D, why it is pinned rather than fixed

Every other row so far has been a per-example concern implemented as process wide state, fixed by resetting that state. Row D is the opposite: the shared state is deliberate. `import_from_git_spec` builds one git repository in a `before :all`, and individual examples append commits, tags and branches to it that later ones assert on, so the group is one scenario written as several examples.

Three ways out were considered. Building a repository per example would be genuinely order independent, but adds a git init, several commits and several tags to each of eleven examples in a group that already takes eleven seconds. Rewriting it as a single example with phases is truthful to the design but loses the naming. Pinning the group with `order: :defined` makes the dependency explicit instead of accidental, costs nothing, and keeps the coverage.

Pinning is the choice for now. It does mean this group no longer contributes evidence of order independence, and it will need revisiting if the suite is ever split across processes, since the group has to stay whole and in order.

### Row M, what made the warning fire is still unknown

The fix makes the spec independent of the problem rather than removing it, and the trigger has not been found. Recorded so the next person does not repeat the search.

`print_bundle_exec_warning` returns early when `FastlaneCore::Helper.bundler?` is true, which it is whenever `BUNDLE_BIN_PATH` or `BUNDLE_GEMFILE` is set. Under `bundle exec`, as CI runs, both are set, so the warning should never appear. It appeared anyway.

Ruled out so far:

- **The working directory.** An earlier version of this note claimed a `Dir.chdir` leak, which was wrong. All seven spec files calling `Dir.chdir` were run individually and each restores it, including `plugin_generator_spec` when its examples fail.
- **`with_env_values` stripping the environment.** It is ClimateControl based, and merges rather than replaces.
- **A spec deleting the bundler variables.** The `ENV.delete` calls in the suite are all `FASTLANE_*` and `DELIVER_*`.

Still worth checking: whether something stubs `Helper.bundler?`, `contained_fastlane?` or `PluginManager#gemfile_path` and leaks the stub, and whether the warning fires through a path other than the one guarded above.

## Reading the counts

The failure set changes with the seed. `spaceship/spec` alone gives 17 failures unseeded and 10 on seed 4242, so these totals are a lower bound on the work rather than a total. Measure progress against a fixed seed, then confirm with a couple of others before considering a row closed.

## Second batch, found after seed 48174 went green

Unpinning the seed immediately found more. Three runs, three seeds, all red, while the subset job passed on all three: everything below is outside the seventeen files this manifest already tracked.

| Seed | Failures |
| --- | --- |
| 1150 | 9 |
| 21323 | 8 |
| 40083 | 11 |

Seven failures are common to all three seeds, so they fail in most orderings and seed 48174 was simply lucky for them:

| Row | Files | Notes |
| --- | --- | --- |
| K | `spaceship/spec/connect_api/spaceship_spec.rb:22,32,42,53` | **fixed**. The group cleared the three client globals in a `before(:all)`, so the explicit client context assigned `ConnectAPI.client` and the implicit client examples inherited it, doubles included. Cleared per example instead |
| L | `fastlane_core/spec/project_spec.rb:345,356` | **fixed**. `Project.xcode_build_settings_timeout` and `_retries` were set with raw `ENV[...] =` assignments. The group's `before` reset them for examples inside it, so nothing looked wrong, but the values leaked out and later examples saw a timeout of 5 where they expected the default 3. Scoped with `with_env_values` |
| M | `fastlane/spec/ruby_version_warning_spec.rb:10` | **fixed in the spec, trigger not identified**. The examples constrain every call to `UI.important`, and `take_off` also emits the bundle exec warning, which failed them. Stubbed, in keeping with the rest of the file, which already mocks most of `take_off`. What made that warning fire is still unknown, see below |

The rest vary by seed, which puts them lower down the ordering space:

| Row | Files | Seen in |
| --- | --- | --- |
| N | `fastlane/spec/actions_specs/flock_spec.rb:20` | **fixed**. `FL_FLOCK_MESSAGE` and `FL_FLOCK_TOKEN` were set with raw assignments. They are the options' `env_name`s, so once set, the option is satisfied and the examples asserting it is required stop raising. Scoped with `with_env_values` |
| O | `fastlane/spec/actions_specs/xcodebuild_spec.rb:712` | **fixed**. Three examples set `XCODE_BUILD_PATH` inline and only two deleted it, and those deletes were in the example body so they were skipped whenever the example failed. Scoped with `with_env_values` |
| P | `gym/spec/platform_detection_spec.rb:32` | 1 of 3, and fails locally in any order, so check whether it is environmental |
| Q | `credentials_manager/spec/account_manager_spec.rb:69` | **fixed** by the environment guard. It read a `DELIVER_PASSWORD` left set by an earlier example. Two attempts to fix it at the source failed because the value is written by `before_each_match`, `before_each_pilot` and `before_each_spaceship`, once per example in those tools, so there was no single setter to scope |
| R | `fastlane/spec/actions_specs/automatic_code_signing_spec.rb:44` | **fixed** by the environment guard. Same shape as Q, with `FASTLANE_TEAM_ID` |
| S | `scan/spec/runner_spec.rb:183,198` | **fixed**. Found by the first unpinned batch, at seed 53367. `NoMethodError: undefined method '[]=' for nil` at `scan/lib/scan/runner.rb:113`, which assigns `Scan.config[:only_testing]`. Every other group in the file builds its own config; the `retry_execute` group did not, and relied on whichever of them ran first leaving one behind. Same shape as row C with `Frameit.config`. Reproduces on its own with `-e retry_execute` |
| T | `deliver/spec/sync_screenshots_spec.rb:15,16` | **fixed**. Found by the parallel spike, not by any seed. The file used a bare `DisplayType`, which nothing in it defines. `deliver/spec/app_screenshot_spec.rb:5`, `app_screenshot_validator_spec.rb:5` and `frameit/spec/template_finder_spec.rb:6` each assign `DisplayType = ...` inside a `describe` block, and a constant assigned in a block takes the block's lexical scope, so all three define a global `::DisplayType` that this file was reading. It fails on its own in any order. Qualified to `Deliver::AppScreenshot::DisplayType`. The three definitions do not conflict with each other, all resolving to the same `Spaceship::ConnectAPI::AppScreenshotSet::DisplayType` object |
| U | `cert/spec/runner_spec.rb:51` | **fixed**. Found at seed 11703. `NoMethodError: undefined method '[]' for nil` at `cert/lib/cert/runner.rb:157`, reading `Cert.config[:type]`. The `"Successful run"` example above it assigns `Cert.config` from its own body rather than a hook, and this one never did, so it passed only when that had run first. Third instance of the same shape after row C's `Frameit.config` and row S's `Scan.config`. Reproduces on its own with `-e "correctly selects expired certificates"` |
| V | `spaceship/spec/spaceauth_spec.rb:49,59` | **fixed**. Found by the subset job at seed 43548, and the first row whose state is not in the process at all. The `check_session` examples assert `exit(0)` for a valid session, and `has_valid_session` (`client.rb:414`) loads a cookie from `persistent_cookie_path`, which is `~/.fastlane/spaceship/<user>/cookie` in the real home directory. The examples never create one, so they passed only when an earlier example had logged in and persisted it. Each example now states the session it is testing. The exit code 1 example was stubbed too: it was passing only because no cookie happened to exist for `unknown-user` |
| W | `scan/spec/detect_values_spec.rb:240,263` | **fixed**. Found at seed 30117. `FastlaneCore::Interface::FastlaneError: Exit status: 64`, which is `xcodebuild -showBuildSettings` rejecting a project, reached through `detect_values.rb:317 get_deployment_target_version`. The `#detect_simulator` group had no `before` at all and read two module level values earlier examples in the same file leave behind: `Scan.config`, without which it raises `NoMethodError` on its own, and `Scan.project`, which production code assigns at `detect_values.rb:30` while detecting values. Given its own config and `Scan.project = nil`, so the deployment target resolves to 0 without shelling out. Reproduces in the single file at seed 30117 |
| X | `deliver/spec/runner_spec.rb` (12), `pilot/spec/manager_spec.rb` (2), and others | **fixed**. Seeds 49524, 10937 and 43881 in three consecutive CI runs, landing in a different file each time, all with the same trace: `#<Double "mock_client"> ... has leaked into another example`, through `Spaceship::ConnectAPI.token` at `spaceship.rb:38`. The source is `spaceship/spec/connect_api/spaceship_spec.rb`, whose `with explicit client` examples stub `Client.login` to return a double that `ConnectAPI.login` then assigns to `@client`. Row K cleared the clients in a `before(:each)`, which keeps that file's own examples honest but hands the last one's double to whatever runs next; rspec has already disabled it by then. Cleared in an `after(:each)` as well. Sixth row on this object after A, B, H, I and K, and the first fix aimed at the source rather than a landing site |

Seeds 48174, 1150, 21323 and 40083 were each pinned in turn while the failures they exposed were worked through, and all four are green. The workflow samples a fresh order per run again as of `f9c6799fc`; the first batch of five turned up one new failure, row S at seed 53367.

## Splitting the suite is its own ordering

`rake test_parallel` runs the suite as several independent rspec processes over a longest-file-first split. It is a spike, not a replacement for `test_all`, and it needs no new gem: `Process.spawn`, one rspec per worker, exit codes aggregated.

It is worth running now rather than after the ordering work, because a split produces contexts no seed ever does. A worker sees a subset, so a file can run with none of the files it has been silently relying on. Row T came out of the first four worker run and no random order had found it in twenty CI runs.

Processes rather than threads, because `ENV` and the working directory are per process in the kernel, so a worker cannot corrupt another through either. That is what makes this safe to try before the environment inventory is worked down. See `internal/notes/test_suite_parallelism.md` for why threads are not the route.

First measurement, four workers on macOS: 106.9s against 236s sequential, a 2.2x. The split is by file size and comes out uneven, 4006 examples in one worker against 1195 in another, so there is room in the balancing before the 27.8s slowest file becomes the floor.

## The environment guard

`spec_helper.rb` snapshots `ENV` around every example, restores it afterwards, and reports every variable an example changed and did not put back. Its point is not only ordering: a spec that leaves a credential in the environment is a leak whatever the concurrency model, and the inventory includes `MAILGUN_APIKEY` and `DANGER_GITHUB_API_TOKEN`.

Restoring is what makes the report worth reading. Without it each example is measured against whatever the previous one left behind, so an example setting a variable to the value already leaked there registers no change and is never named. `sigh/spec/manager_spec.rb`, `sigh/spec/runner_spec.rb` and `pem/spec/manager_spec.rb` all set `DELIVER_PASSWORD` to `"123"`: reporting without restoring names one of the 64 examples in those files, restoring names all 64. That is why the first local and CI inventories disagreed at 35 and 33 while finding the same variables. The counts were an artefact of the order, not a difference in what leaked.

With restoring on, the full suite reports the same 35 variables with the same counts at defined order and at seed 40083:

| Variable | Examples |
| --- | --- |
| `DELIVER_PASSWORD`, `DELIVER_USER` | 1336 each |
| `FASTLANE_LANE_NAME` | 1202 |
| `SPACESHIP_AVOID_XCODE_API` | 915 |
| `DELIVER_HTML_EXPORT_PATH` | 130 |
| `FASTLANE_PLATFORM_NAME` | 43 |
| `FASTLANE_IS_INTERACTIVE` | 13 |
| `FASTLANE_TEAM_ID` | 10 |
| `CER_CERTIFICATE_ID`, `CER_FILE_PATH`, `CER_KEYCHAIN_PATH` | 8 each |
| `BUNDLE_GEMFILE`, `BUNDLE_BIN_PATH` | 5 each |
| `MAILGUN_APIKEY`, `MAILGUN_APP_LINK`, `MAILGUN_SANDBOX_POSTMASTER`, `FASTLANE_OPT_OUT_USAGE` | 4 each |
| `FASTLANE_SKIP_DOCS` | 3 |
| 4 more, including `FASTLANE_TEAM_NAME` and `PRODUCE_TEAM_NAME` | 2 each |
| 13 more, including `DANGER_GITHUB_API_TOKEN`, `SIGH_UUID` and `ANDROID_SDK_ROOT` | 1 each |

## The singleton guard

Four rows were the same defect: a group reading module level configuration it never sets, green only while an earlier example happened to leave a value behind. Row C was `Frameit.config`, S was `Scan.config`, U was `Cert.config`, W was `Scan.config` and `Scan.project` together. Fixing them one at a time only catches what a seed exposes, and W survived roughly twenty five random orders before one did.

`spec_helper.rb` now clears these after every example, so a group that depends on one fails every time rather than occasionally. The accessors are read off each tool's `module.rb` `class << self` block, plus `supply/lib/supply.rb`, which keeps its accessor elsewhere and would have been missed by looking only at `module.rb`:

| Module | Cleared |
| --- | --- |
| `Scan` | `config`, `project`, `cache`, `devices` |
| `Gym`, `Snapshot` | `config`, `project`, `cache` |
| `Screengrab` | `config`, `android_environment` |
| `Cert`, `Frameit`, `PEM`, `Precheck`, `Produce`, `Sigh`, `Supply` | `config` |
| `Deliver` | `cache` |

The ivars are cleared rather than assigned through the writers. `Scan`, `Gym` and `Snapshot` define `config=` to run detection and reset their cache as a side effect, so assigning nil would run detection against a nil config.

With the guard on, the full suite at defined order gains no failures at all, which says C, S, U and W were the only instances in the suite rather than the only ones a seed had found. The guard was checked against a probe rather than inferred from that zero: one example assigns `Scan.config` and `Scan.project`, the next asserts both are nil, and it passes with the guard on and fails with `FASTLANE_SPEC_SINGLETON_GUARD=off`.

`Spaceship::ConnectAPI.client`, `Tunes.client` and `Portal.client` are deliberately not in the list. They are the same shape and account for rows A, B, H, I and K, but clearing them per example took `spaceship/spec` from 10 failures to 13 on a fixed seed, because some specs rely on the client persisting. They need individual work, not a blanket reset.

`scan/spec/xcpretty_reporter_options_generator_spec.rb` set `Scan.config` in a `before(:all)`, a one shot that only serves the first example once the guard clears between them. Moved to `before(:each)`, as row K was. It was the only such case in the suite.

The top four environment variables are not four hundred careless specs. `before_each_match`, `before_each_pilot` and `before_each_spaceship` each assign `DELIVER_USER` and `DELIVER_PASSWORD` on every example of their tool, so every match, pilot and spaceship example is counted. Fixing those three methods accounts for most of the list.

Restoring costs nothing measurable: the full suite is 7863 examples and 2 failures with the guard enforcing, and the same 2 fail with the guard switched off entirely. Those two are `plugin_generator_spec` shelling out to rubocop in the generated plugin, which fails locally and passes in CI, so they are environmental rather than ordering.

`FASTLANE_SPEC_ENV_GUARD_REPORT` names a file to write the full inventory to, key by key and example by example. The console prints three ids per variable, which is not enough to work from when a variable has 1336.

What the guard cannot see, because both run outside `around(:each)`: a top level `ENV` write in a tool spec helper, which is checked for separately and currently finds nothing, and a write in a `before(:context)` hook, which enters the baseline of every example in the group and outlives it.

It also does not see state that is not in the process. Row V was a cookie the suite writes to `~/.fastlane/spaceship/<user>/cookie`, and on this machine the file was dated nine months before the run that depended on it, so the examples passed locally in every order while failing on CI. `/tmp/spaceship_itc_service_key.txt` (`client.rb:757`) is cached the same way. Neither the guard nor process based parallelism helps here, because a forked worker inherits the same home directory. `SPACESHIP_COOKIE_PATH` (`client.rb:294`) redirects the cookie store, and `spec_helper.rb` now points it at a temporary directory belonging to the run, removed in an `after(:suite)`. The suite no longer writes to `~/.fastlane`, and a spec that needs a session has to arrange one rather than finding one. Verified two ways: `persistent_cookie_path` resolves under the temporary directory with no `~/.fastlane` in it, and the cookie file on this machine keeps its modification time across a run that previously rewrote it.

`fastlane_user_dir` (`client.rb:285`) is still `File.expand_path(File.join(Dir.home, ".fastlane"))` with no override, so anything else reaching for that directory is unaffected. `/tmp/spaceship_itc_service_key.txt` (`client.rb:757`) is likewise still cached outside the run.

### Finding the source of an order dependent failure cheaply

Row X took minutes rather than hours because of a shortcut worth reusing. `rspec --bisect` over the whole suite means many runs of 449 files, but the culprit always ran *before* the failure, so the search space is only the prefix:

```
rspec --order random:<seed> --dry-run --format json --out order.json
```

`--out` matters, since `spec_helper.rb` redirects `$stdout` and the JSON would otherwise land in its temporary file. Take every file up to the failing one, confirm those alone reproduce, then bisect that. For row X the prefix was 23 files of 449, and bisect went from 223 non failing examples to 1 in 17 seconds.

### Confirmed on CI, and what the inventory is still relative to

Run 34447177995, seed 1150, macOS 15 with Ruby 3.4: 7863 examples and 0 failures on the full suite, 352 and 0 on the subset. The same example count as locally, so the two local `plugin_generator_spec` failures are environmental as suspected, not ordering.

CI reports 33 variables against the 35 seen locally, and its set is a strict subset: no variable appears there that does not appear locally. The missing two are `FASTLANE_IS_INTERACTIVE` and `FASTLANE_SKIP_DOCS`, both written by `fastlane/spec/cli_tools_distributor_spec.rb`, which runs in both. `FASTLANE_OPT_OUT_USAGE` is 3 there against 4 here, the missing example being `opt_out_usage_spec`.

The cause is the environment the suite inherits rather than the order it runs in. CI runs `bundle exec fastlane execute_tests`, and that fastlane invocation has already set all three by the time rspec starts: `Fastfile` lines 4 and 5 call `skip_docs` and `opt_out_usage`, and `cli_tools_distributor.rb:84` assigns `FASTLANE_IS_INTERACTIVE`. Running `bundle exec rspec` directly, as the local numbers were taken, leaves them unset. A spec writing the value that is already there changes nothing, so the guard has nothing to report.

So the inventory is order independent, which is what it was changed for, but it is still relative to the ambient environment: a variable already carrying the value a spec assigns stays invisible. Closing that means recording the writes rather than diffing the end state, by prepending to `ENV`'s singleton the four methods that mutate it and having `with_env_values` mark the keys it is responsible for so the sanctioned wrapper is not reported. Worth doing when the current list is worked down, not before: the gap is two known variables in one known file, and the write recorder cannot by itself tell a scoped write from an unscoped one, which is why it is not the whole mechanism.

## The list

Everything identified so far, from CI or locally. `rake test_order_dependent` reads the paths from this block.

```text
spaceship/spec/spaceship_spec.rb
spaceship/spec/spaceauth_spec.rb
spaceship/spec/portal/certificate_spec.rb
spaceship/spec/portal/portal_permission_spec.rb
spaceship/spec/two_step_or_factor_client_spec.rb
spaceship/spec/connect_api/models/device_spec.rb
spaceship/spec/connect_api/models/certificate_spec.rb
spaceship/spec/connect_api/models/build_beta_detail_spec.rb
spaceship/spec/connect_api/models/beta_build_metric_spec.rb
spaceship/spec/connect_api/models/app_store_version_release_request_spec.rb
spaceship/spec/connect_api/models/build_delivery_spec.rb
frameit/spec/editor_spec.rb
fastlane/spec/actions_specs/import_from_git_spec.rb
fastlane/spec/actions_specs/notification_spec.rb
fastlane/spec/actions_specs/automatic_code_signing_spec.rb
fastlane_core/spec/command_executor_spec.rb
fastlane_core/spec/device_manager_spec.rb
supply/spec/uploader_spec.rb
spaceship/spec/connect_api/spaceship_spec.rb
fastlane_core/spec/project_spec.rb
fastlane/spec/ruby_version_warning_spec.rb
fastlane/spec/actions_specs/flock_spec.rb
fastlane/spec/actions_specs/xcodebuild_spec.rb
gym/spec/platform_detection_spec.rb
credentials_manager/spec/account_manager_spec.rb
scan/spec/runner_spec.rb
deliver/spec/sync_screenshots_spec.rb
cert/spec/runner_spec.rb
scan/spec/detect_values_spec.rb
spaceship/spec/client_spec.rb
deliver/spec/runner_spec.rb
pilot/spec/manager_spec.rb
```

Deliberately excluded: `fastlane_core/spec/project_spec.rb` and `fastlane/spec/plugins_specs/plugin_generator_spec.rb`. They fail locally in any order, including the normal one, so they are environmental rather than order dependent.
