# Notes

Working notes from the test suite work in fastlane#30184 and fastlane#30189.

These are not documentation for using fastlane, and they are not a plan. They are the reasoning and the measurements behind decisions that are otherwise invisible in the code: why the suite is split across processes rather than threads, how many workers to run and where the numbers came from, and which approaches were tried and reverted.

That last one is the reason this directory exists. A reverted commit leaves nothing in the history that anyone reads, so the next person to have the same good idea has to rediscover why it does not work. Both attempts in `xcodebuild_build_settings.md` look obviously correct until they are run on a clean machine.

| | |
| --- | --- |
| `test_suite_parallelism.md` | Why processes and not threads or Ractors, and what oversubscribing the core count buys |
| `ci_and_developer_config.md` | How many workers, on CI and locally, and the measurements behind the numbers |
| `xcodebuild_build_settings.md` | Two reverted attempts at making the specs stop shelling out to xcodebuild, and why neither was caught locally |

They record what was true when they were written, and each says when that was.
