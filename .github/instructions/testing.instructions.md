---
applyTo:
  - "**/spec/**"
  - "**/*_spec.rb"
  - "spec/spec_helper.rb"
---

Specs follow [Testing.md](../../docs/Testing.md). When a change adds or changes specs, check in particular:

- A spec added for a fix must fail against the code before the fix. If it would also pass on the old code, it proves nothing: say which example and why.
- Every combination the change touches is covered. For options that can replace each other: each one alone, both together, and neither.
- A spec does not depend on the developer's environment. Options with an `env_name` (e.g. `KEYCHAIN_NAME`, `KEYCHAIN_PATH`) are set or cleared with `FastlaneSpec::Env.with_env_values`, so a variable exported on the machine cannot change the result.
