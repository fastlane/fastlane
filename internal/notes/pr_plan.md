# Slicing this branch into pull requests

`chore/random_order_audit` is 69 commits against master. It was worked as one branch on purpose, because the failures only make sense together, but it should not be reviewed as one. Written 2026-09-10.

## Commits that should not survive

Four pairs cancel out and should be dropped rather than rebased:

- `2655245d8` and its revert `f97a6de7f`, recording xcodebuild build settings to fixtures.
- `10740cd41` and its revert `70372e974`, memoising them per run.
- `5886100db` and `944842d71` are a cherry-pick of PR #30178 and belong to that PR, not here. They were carried temporarily so CI would exercise the security gem's `main` alongside this work.

Both reverted attempts are written up in `internal/notes/xcodebuild_build_settings.md`, which is where that work should live until somebody takes it further.

Several sequences are churn that should be squashed:

- `8ba265bf5`, `137972f37`, `f9c6799fc`: unpin the seed, pin it again, unpin it. The net effect is unpinned.
- `e2efebcca` then `b2de30b70`: the environment guard, then reworking it to report the same leaks in any order.
- `150456cb1` then `d024e87cb`: the cookie store, then fixing what it broke in `client_spec`.
- `7926fdbd8`, `75ceb56a5`, `80b78c641`: three passes at how the parallel job reports and gates.
- `2655245d8` aside, `554d8effb` and `a7b792c95` and `2eb1a9be1` are one story about balancing the split.

`f9dcc1d91` does two unrelated things, the plugin generator's ordering and regenerating its rubocop config before tests, and wants splitting.

The documentation commits, fifteen of them, mostly iterate on `internal/order_dependent_specs.md` as the investigation went. They should collapse into the pull requests they describe rather than travelling as their own history.

## Suggested pull requests

**1. Module level configuration leaks between examples.** The largest and most self-contained group: `Frameit.config`, `Scan.config`, `Scan.project`, `Cert.config`, and the guard in `spec_helper.rb` that clears them all after each example. Four rows of the table were this one defect, and the guard closes the class rather than the instances. Commits: `b1e2dfab5`, `80dcf15d3`, `86646af35`, `05d0fc37f`, `4c95b43d8`, plus the `before(:all)` change in `xcpretty_reporter_options_generator_spec`.

**2. Spaceship client singletons.** `Spaceship::ConnectAPI.client`, `Tunes.client`, `Portal.client` outliving the example that set them, which accounts for six rows. Deliberately not solved by a blanket reset, which was tried and made things worse. Commits: `f26c4e79b`, `06ee1e635`, `dde0e8db0`, `f51ddd6d8`, `5d9de323a`.

**3. Environment variables.** The guard that snapshots and restores `ENV` per example, and the specs that were leaking. Includes credentials: `DELIVER_PASSWORD`, `MAILGUN_APIKEY`, `DANGER_GITHUB_API_TOKEN`. Commits: `5742e6385`, `6f4bc3f41`, `e2efebcca`+`b2de30b70` squashed, `4888b5145`.

**4. State outside the process.** Specs depending on files in `~` or `/tmp` that an earlier run left: the spaceship cookie, the service key cache, the harness's own log file read as a screenshot fixture. Plus `rake test_isolated`. This is the group that only fails on a clean machine, so it is also the group most worth landing. Commits: `3f751fb5d`, `150456cb1`+`d024e87cb` squashed, `85a81a7a3`, `7dc13d17c`, `eea089f59`, `8ce400604`.

**5. Individual ordering fixes.** What does not fit a theme: `import_from_git` pinned to its defined order, `command_executor`'s `Process.wait` mocks and its banner, `supply` and `notification`, `DisplayType` in `sync_screenshots_spec`, `spaceauth`'s session, the plugin generator's `before(:all)`. Commits: `26746a7ef`, `5fc2b74fd`, `f00c8c16d`, `bbf7af4ab`, `ad75aaf8d`, `e6a1701ea` (spec part), `3fa520fba`, `f9dcc1d91` (ordering part).

**6. Running the suite in parallel.** `rake test_parallel` and `rake spec_timings`, balanced on measured durations, splitting files heavier than a worker's share, and the worker default. Independent of everything above except that it needs the ordering work to have landed first. Commits: `e6a1701ea` (rake part), `554d8effb`, `a7b792c95`, `2eb1a9be1`, `7926fdbd8`.

**7. Regenerate the plugin template's rubocop config before tests.** One line in the `Rakefile`, from `f9dcc1d91`. Small and unrelated to the rest: a stale generated file makes `plugin_generator_spec` fail with `expected 0, got 1` and no other clue.

**8. The audit workflow itself.** `.github/workflows/random-order-audit.yml`. Branch scoped today. Whether this belongs on master at all is a question for the team: it is 9 jobs and takes 11 minutes. A reduced version, the random order job on a schedule, is probably what is wanted.

**9. The notes.** `internal/order_dependent_specs.md`, `internal/notes/*`. Could ride along with 1 to 6, or land once as the record of the investigation.

Already open: **#30178**, the security gem integration, which is independent of all of this.

## Issues worth opening

**fastlane adds certificates to the user's keychain when it parses a provisioning profile.** `security cms -D` imports the signing certificate in order to verify the signature, and fastlane calls it in `verify_build.rb`, `provisioning_profile.rb` and `sigh/local_manage.rb`. A test run puts four certificates in the default keychain. `provisioning_profile.rb` already has a `-k <keychain_path>` variant, so there is a mechanism for directing it somewhere chosen. This is production behaviour, not a test artefact.

**The suite writes to the developer's home directory and does not clean up.** 53 entries after one run, 83 after two: `~/.fastlane`, `~/Library/Logs` for four tools, provisioning profiles, `~/.appstoreconnect`, a rubocop cache.

**`FastlanePty` reports the exit status of whatever the thread ran last.** Parked with a patch and notes in `internal/notes/fastlane_pty_status.md`. Not an ordering problem; found while fixing one.

## Work still to do

The isolated home costs 7% locally and 60% on a macOS runner, 242s against 151s at four workers. Unexplained.

Windows is not measured at all. `ci.yml` covers it, this audit does not.

The environment guard restores `ENV` after each example, so leaks no longer reach other specs, but 35 variables are still being left behind by the specs that set them. Declaring them with `env_output:` or scoping them with `with_env_values` is follow-up work, tracked by the guard's own report.

Row Z is fixed but `spaceship/spec/tunes/tunes_client_spec.rb` is worth watching: it was the only defect that needed several attempts, and the first two made things worse.

The security gem needs a 0.3.0 release before #30178 can drop its git source and pin `~> 0.3`.

## What happens to this branch

It is scaffolding, and it should be deleted rather than kept once the pull requests have landed.

fastlane squash merges. Every pull request arrives on master as a single new commit with `(#NNNNN)` appended, and there has not been a real merge commit since 2017. Two consequences follow, and both are the answer to "can we rebuild this branch afterwards".

**The branch cannot be reconstructed by merging the pull requests back.** Squashing replaces a branch's commits with one commit at a different sha and different patch boundaries, so there is no shared history to merge against. It would conflict or duplicate.

**Rebasing this branch onto master as pull requests land will also conflict.** Git can sometimes drop commits it recognises as already applied, by patch id, but squashing changes the boundaries so it usually will not recognise them. Expect to resolve the same change twice.

So the model is that the content migrates to master through the pull requests, and master becomes the result. While extraction is in progress:

- freeze this branch as the reference and stop adding work to it
- cut each pull request branch from `master`, cherry picking what it needs
- do not rebase this branch as things land. If a combined branch is still wanted for running the audit, recreate it from master plus whatever has not merged yet

**Land the workflow early.** The audit only exists today because this branch exists. Once `.github/workflows/random-order-audit.yml` is on master, in whatever reduced form the team wants, the capability survives independently of the branch.

**Land the notes early, and check their references first.** Four issues, #30186, #30187, #30188 and #30189, point at this investigation, and these notes are the record behind them. Anything citing a sha from this branch becomes a dangling reference the moment the branch is deleted. Five such references have been rewritten to describe the change instead. This file is the exception: it is about the extraction, it cites 57 of them, and it should not land on master at all.
