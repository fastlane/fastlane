# Order dependent specs

The suite passes in the order rspec happens to load files in, and fails in others. See fastlane#30184. This file is the working list, and it is also the input to `rake test_order_dependent`, so the table and the list below it stay in step.

Counts come from two runs at the time of writing: CI on `chore/random_order_audit` at seed 48174 (7847 examples, 48 failures), and the same seed locally on macOS with Ruby 4.0.5 (39 failures). A row failing in one and not the other is not noise to be ignored, it is a hint about what the failure depends on.

Entries stay in the list until the whole suite is stable, not until their own row closes. A file that has just been fixed is exactly the one worth re-running in new orderings.

| Row | CI | Local | Files | Symptom | Likely cause | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A | 16 | 1 | `spaceship/spec/spaceship_spec.rb` (10), `spaceauth_spec.rb` (6) | `WebMock::NetConnectNotAllowedError` on `POST https://idmsa.apple.com/appleauth/auth/signin/init` | A login ran without the SIRP stub, so a real SRP value was computed and matched none of the recorded request bodies | **fixed** in `b63ab357a`, confirmed at seed 48174: all 16 gone, no `signin/init` request blocked anywhere in the run |
| B | 15 | 15 | `connect_api/models/`: `device_spec.rb` (8), `certificate_spec.rb` (3), `build_beta_detail_spec.rb`, `beta_build_metric_spec.rb`, `app_store_version_release_request_spec.rb`, `build_delivery_spec.rb` | `TypeError: You need to instantiate this module with provisioning_request_client`, also `test_flight_request_client` and `tunes_request_client` | ConnectAPI sub-clients are module level state that an earlier example instantiates and later ones inherit | **fixed**, confirmed locally at seed 48174: 39 to 24, exactly these 15, nothing new |
| C | 5 | 5 | `frameit/spec/editor_spec.rb` | `undefined method '[]' for nil` at `frameit/lib/frameit/screenshot.rb:45` | `Frameit.config` is module level state, normally set by the commands generator. `editor_spec` only sets it in the `frame!` group, so the `should_skip?` and `fetch_text` groups relied on an earlier example leaving one behind | **fixed**, confirmed locally at seed 48174: 24 to 19, exactly these 5, nothing new |
| D | 4 | 4 | `fastlane/spec/actions_specs/import_from_git_spec.rb` | `FastlaneCore::UI received :important with unexpected arguments`, `expected: 0 times with arguments: (/git checkout/)` | Message expectations that assume the action has not already run and cached in this process | open |
| E | 2 | 2 | `fastlane_core/spec/command_executor_spec.rb` | `FastlaneCore::Interface::FastlaneError` | Not yet investigated | open |
| G | 5 | 5 | `fastlane_core/spec/device_manager_spec.rb`, `fastlane/spec/actions_specs/notification_spec.rb`, `fastlane/spec/actions_specs/automatic_code_signing_spec.rb`, `spaceship/spec/two_step_or_factor_client_spec.rb`, `supply/spec/uploader_spec.rb` | assorted | Singles, triaged individually. The supply one looks like a genuine test bug rather than ordering: it calls `all_languages`, which is private | open |
| H | 1 | 1 | `spaceship/spec/portal/portal_permission_spec.rb` | | Not a regression after all. `spaceship_spec.rb` stamps a client onto model classes through `set_client`, and this spec then reads it instead of the one its own login produced. It only surfaced once row A stopped `spaceship_spec.rb` failing early, so the leak had always been there | **fixed** with row I, 19 to 17 |
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

## Reading the counts

The failure set changes with the seed. `spaceship/spec` alone gives 17 failures unseeded and 10 on seed 4242, so these totals are a lower bound on the work rather than a total. Measure progress against a fixed seed, then confirm with a couple of others before considering a row closed.

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
```

Deliberately excluded: `fastlane_core/spec/project_spec.rb` and `fastlane/spec/plugins_specs/plugin_generator_spec.rb`. They fail locally in any order, including the normal one, so they are environmental rather than order dependent.
