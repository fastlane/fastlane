# Working on _fastlane_

_fastlane_ is one Ruby gem built from several tools in this repository: _fastlane_ itself (actions and lanes), `fastlane_core` (shared code), _spaceship_ (Apple APIs), _match_, _gym_, _pilot_ and others. Actions live in `fastlane/lib/fastlane/actions/`.

## Checks

CI runs these; run them before pushing:

- `bundle exec rake test_parallel`: the spec suite, split across processes as on CI ([Testing.md](Testing.md))
- `bundle exec fastlane lint_source`: RuboCop and other source checks
- `bundle exec fastlane validate_docs`: action documentation

## Guides

Read the guides for the files a change touches, and apply their rules:

| Change | Guide |
|---|---|
| An action, its options or its outputs | [Design.md](Design.md) |
| Specs | [Testing.md](Testing.md), [ParallelTesting.md](ParallelTesting.md) |
| Anything else | prefer the pattern the codebase already uses for the same problem |

## Rules

- One concern per pull request.
- A fix comes with a spec that fails without it ([Testing.md](Testing.md#writing-a-spec-for-a-fix)).
- When a change introduces a new pattern where the codebase already has one, name the existing one and say why it does not fit.
- Report security problems privately to the maintainers, not in issues, pull requests or reviews.
