---
name: code-review
description: Use when reviewing a pull request to fastlane.
---

# Reviewing a _fastlane_ pull request

Hold the change to [AGENTS.md](../../../AGENTS.md) and the guides it lists for the files the pull request touches.

## Understand intent first

- Read the issue the description links ("Resolves #N", "Fixes #N") and its comments with the GitHub MCP server, then the description. Review the change against what the issue asks, including any request to audit, discuss or check other places before changing this one. Report it when that was not done.
- Search for earlier pull requests and issues about the same code, to find decisions already made.

## Verify before reporting

- Check every claim against the code before raising it. Do not post a finding you could not confirm.
- If the change introduces or exposes a vulnerability, do not describe it, show how to exploit it, or suggest a fix that reveals it. Leave one short comment that the change needs a security review by a maintainer before it is merged, without details.

## What to look for

### Blocking

- A fix whose spec would also pass against the code before the fix.
- New behaviour without a spec for each branch, validator and error case.
- A new pattern where the codebase already solves the same problem. Name the existing one: for two options that can replace each other, `delete_keychain` (`:name` and `:keychain_path`).
- A change that contradicts [Design.md](../../../Design.md), or works around one of its known limits in a single action.
- A bug, or a change to an action's options, defaults or outputs that breaks existing Fastfiles.
- `example_code`, `details` or option descriptions that no longer match what the code does after the change.

### Non-blocking

- A simpler way to write the same thing.
- Naming, comments, readability.

### Scope

- One concern per pull request: name what to split out.

## Reporting

Give each finding its file and line, and the guide rule it rests on.
