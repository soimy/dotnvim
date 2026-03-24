# AGENT.md

This repository is a personal cloud-synced configuration project.

## Agent Constraints

- Prefer direct, pragmatic edits over heavyweight process.
- Do not require heavy TDD for simple shell, config, or documentation changes.
- Do not require git worktrees by default.
- Working directly on the current branch is acceptable unless the user explicitly asks for isolated development.
- Use lightweight verification that matches the scope of the change, such as shell syntax checks, smoke tests, or targeted manual verification.
- Do not block straightforward maintenance work on spec-writing or process-heavy planning unless the user explicitly asks for that workflow.
- Never revert unrelated user changes in the worktree.
