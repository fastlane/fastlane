# Order dependent specs

The suite passes in the order rspec happens to load files in, and fails in others. See fastlane#30184. This file is the working list, and it is also the input to `rake test_order_dependent`, so the table and the list below it stay in step.

Counts come from two runs at the time of writing: CI on `chore/random_order_audit` at seed 48174 (7847 examples, 48 failures), and the same seed locally on macOS with Ruby 4.0.5 (39 failures). A row failing in one and not the other is not noise to be ignored, it is a hint about what the failure depends on.

Entries stay in the list until the whole suite is stable, not until their own row closes. A file that has just been fixed is exactly the one worth re-running in new orderings.

| Row | CI | Local | Files | Symptom | Likely cause | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A | 15 | 1 | `spaceship/spec/spaceship_spec.rb` (10), `spaceauth_spec.rb` (4), `portal/certificate_spec.rb` (1) | `WebMock::NetConnectNotAllowedError` on `POST https://idmsa.apple.com/appleauth/auth/signin/init` | A login runs without the SIRP stub, so a real SRP value is computed and matches none of the recorded request bodies. Only the `portal/certificate_spec.rb` failure reproduces locally, and it has not been confirmed to share this cause | open, diagnostics added |
| B | 15 | 15 | `connect_api/models/`: `device_spec.rb` (8), `certificate_spec.rb` (3), `build_beta_detail_spec.rb`, `beta_build_metric_spec.rb`, `app_store_version_release_request_spec.rb`, `build_delivery_spec.rb` | `TypeError: You need to instantiate this module with provisioning_request_client`, also `test_flight_request_client` and `tunes_request_client` | ConnectAPI sub-clients are module level state that an earlier example instantiates and later ones inherit | open |
| C | 5 | 5 | `frameit/spec/editor_spec.rb` | `undefined method '[]' for nil` at `frameit/lib/frameit/screenshot.rb:45` | Something another spec's setup populates is nil here | open |
| D | 4 | 4 | `fastlane/spec/actions_specs/import_from_git_spec.rb` | `FastlaneCore::UI received :important with unexpected arguments`, `expected: 0 times with arguments: (/git checkout/)` | Message expectations that assume the action has not already run and cached in this process | open |
| E | 2 | 2 | `fastlane_core/spec/command_executor_spec.rb` | `FastlaneCore::Interface::FastlaneError` | Not yet investigated | open |
| F | 2 | 0 | `spaceship/spec/spaceauth_spec.rb` | `expected: 0` | Not yet investigated. Same file as part of A but a different failure | open |
| G | 5 | 5 | `fastlane_core/spec/device_manager_spec.rb`, `fastlane/spec/actions_specs/notification_spec.rb`, `fastlane/spec/actions_specs/automatic_code_signing_spec.rb`, `spaceship/spec/two_step_or_factor_client_spec.rb`, `supply/spec/uploader_spec.rb` | assorted | Singles, triaged individually. The supply one looks like a genuine test bug rather than ordering: it calls `all_languages`, which is private | open |
| H | 0 | 1 | `spaceship/spec/portal/portal_permission_spec.rb` | | Local only, did not appear in the CI run | open |

A and B are 30 of the 48 and share a cause: module level singletons in spaceship outliving the example that created them. The obvious remedy does not work. Adding an `after(:each)` that nils `Spaceship::Tunes.client`, `Portal.client` and `ConnectAPI.client` took `spaceship/spec` from 10 failures to 13 on a fixed seed, so some specs rely on the client persisting.

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
