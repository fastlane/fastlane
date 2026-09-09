# Order dependent specs

The suite passes in the order rspec happens to load files in, and fails in others. See fastlane#30184. This file is the working list, and it is also the input to `rake test_order_dependent`, so the table and the list below it stay in step.

Counts come from two runs at the time of writing: CI on `chore/random_order_audit` at seed 48174 (7847 examples, 48 failures), and the same seed locally on macOS with Ruby 4.0.5 (39 failures). A row failing in one and not the other is not noise to be ignored, it is a hint about what the failure depends on.

Entries stay in the list until the whole suite is stable, not until their own row closes. A file that has just been fixed is exactly the one worth re-running in new orderings.

| Row | CI | Local | Files | Symptom | Likely cause | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A | 15 | 1 | `spaceship/spec/spaceship_spec.rb` (10), `spaceauth_spec.rb` (4) | `WebMock::NetConnectNotAllowedError` on `POST https://idmsa.apple.com/appleauth/auth/signin/init` | A login ran without the SIRP stub, so a real SRP value was computed and matched none of the recorded request bodies | likely fixed, needs confirming on the pinned seed |
| B | 15 | 15 | `connect_api/models/`: `device_spec.rb` (8), `certificate_spec.rb` (3), `build_beta_detail_spec.rb`, `beta_build_metric_spec.rb`, `app_store_version_release_request_spec.rb`, `build_delivery_spec.rb` | `TypeError: You need to instantiate this module with provisioning_request_client`, also `test_flight_request_client` and `tunes_request_client` | ConnectAPI sub-clients are module level state that an earlier example instantiates and later ones inherit | open |
| C | 5 | 5 | `frameit/spec/editor_spec.rb` | `undefined method '[]' for nil` at `frameit/lib/frameit/screenshot.rb:45` | Something another spec's setup populates is nil here | open |
| D | 4 | 4 | `fastlane/spec/actions_specs/import_from_git_spec.rb` | `FastlaneCore::UI received :important with unexpected arguments`, `expected: 0 times with arguments: (/git checkout/)` | Message expectations that assume the action has not already run and cached in this process | open |
| E | 2 | 2 | `fastlane_core/spec/command_executor_spec.rb` | `FastlaneCore::Interface::FastlaneError` | Not yet investigated | open |
| F | 2 | 0 | `spaceship/spec/spaceauth_spec.rb` | `expected: 0` | Not yet investigated. Same file as part of A but a different failure | open |
| G | 5 | 5 | `fastlane_core/spec/device_manager_spec.rb`, `fastlane/spec/actions_specs/notification_spec.rb`, `fastlane/spec/actions_specs/automatic_code_signing_spec.rb`, `spaceship/spec/two_step_or_factor_client_spec.rb`, `supply/spec/uploader_spec.rb` | assorted | Singles, triaged individually. The supply one looks like a genuine test bug rather than ordering: it calls `all_languages`, which is private | open |
| H | 0 | 1 | `spaceship/spec/portal/portal_permission_spec.rb` | | Local only, did not appear in the CI run | open |
| I | 2 | 0 | `spaceship/spec/portal/certificate_spec.rb` | `WebMock::NetConnectNotAllowedError` on `POST .../certificate/submitCertificateRequest.action` | Missing stub for certificate submission, not a login problem. Previously counted under A because both are blocked requests; the diagnostics separated them | open |

### Update, run at seed 58148

Moving the SIRP stubbing to every spaceship example (commit `b63ab357a`) appears to have cleared row A: that run blocked no `signin/init` request at all. Two blocked requests remained in `portal/certificate_spec.rb`, and the diagnostics showed them to be certificate submission rather than login, which is now row I.

That run also totalled 62 failures against 48 at seed 48174. The seeds differ, so the two are not comparable, and 48 was a lower bound as expected. The full job now pins seed 48174 so successive runs measure the same thing; the subset job deliberately does not, so it keeps sampling new orderings.

The diagnostics were wrong in their first form and reported `SRP value was the stubbed one: false` for a request that was not a login at all. The constant is hex and the request body carries its base64, so the comparison could never be true. Fixed to compare the base64 and to only make the claim for `signin/init` requests.

A and B were 30 of the 48 and share a cause: module level singletons in spaceship outliving the example that created them. The obvious remedy does not work. Adding an `after(:each)` that nils `Spaceship::Tunes.client`, `Portal.client` and `ConnectAPI.client` took `spaceship/spec` from 10 failures to 13 on a fixed seed, so some specs rely on the client persisting.

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
