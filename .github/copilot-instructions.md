When the pull request description references an issue ("Resolves #N"), read that issue and check the change against what it asks for, including any request to audit related code first.

Prefer the existing mechanisms over new ones: option validation belongs in `FastlaneCore::ConfigItem` (`optional`, `conflicting_options`, `verify_block`), not in an action's `run` method. Flag code that introduces a pattern no other action uses.

Options read from environment variables are not checked by `conflicting_options`. This is a known framework gap: do not suggest per-action workarounds for it.

Tests for a fix should fail without the fix; flag tests that only exercise the happy path.

Ruby code must keep working on the minimum Ruby version in `fastlane.gemspec`.
