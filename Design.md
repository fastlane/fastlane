# Designing _fastlane_ code

Conventions a change is reviewed against. When a change needs something these do not cover, prefer the pattern the codebase already uses for the same problem, and say so in the pull request when you introduce a new one.

## Action options

Options are declared with `FastlaneCore::ConfigItem` in `available_options`, and validated there rather than in `run`:

- `optional: false` for a required option. It is enforced when the value is fetched, not when the configuration is built, so an option that `run` never reads is never checked.
- `verify_block` for the value of a single option.
- `conflicting_options` for options that cannot be used together, with `conflict_block` when the error needs a custom message.

A value is resolved in this order: the parameter passed to the action, then `env_name`, then the configuration file, then `default_value`.

Known limits, which a change should not work around in a single action:

- `conflicting_options` only compares options passed as parameters. Values read from environment variables are fetched later and are not compared.
- `ConfigItem` has no "at least one of" mechanism. Checking that in `run` is the accepted pattern, as `delete_keychain` does for `:name` and `:keychain_path`.

Environment variable names are shared between actions: `KEYCHAIN_NAME` is read by `create_keychain`, `delete_keychain` and `import_certificate`. A variable a user exports for one action is seen by the others.
