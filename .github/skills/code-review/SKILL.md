---
name: code-review
description: Reviewing a pull request to fastlane. Use for every pull request review.
---

1. If the description references an issue ("Resolves #N"), fetch it and its comments with the GitHub MCP server. Review the change against what the issue asks, including any request to audit or discuss before implementing.
2. Read Design.md, and Testing.md and ParallelTesting.md when specs change. Point to the rule a finding is based on.
3. Prefer the pattern the codebase already uses for the same problem. When a change introduces a new pattern, flag it and name the existing one.
