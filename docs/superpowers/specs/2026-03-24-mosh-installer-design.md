# Mosh Installer Design

**Date:** 2026-03-24

## Goal

Add a standalone automation script for `mosh` that matches the repository's existing deployment style: install the `mosh` package on the local machine and provision a reusable user-level wrapper command.

## Why A Standalone Script

`mosh` is not a Neovim dependency in the same way `git`, `fd`, or `tree-sitter` are. Keeping it out of `bootstrap.sh` preserves the current contract of the Neovim bootstrap flow while still letting this repository automate adjacent terminal tooling, similar to `scripts/install-global-tmux-config`.

## Scope

The new workflow will:

- install `mosh` on the current machine using the platform package manager
- create `~/.local/bin/mosh-connect`
- make `mosh-connect` a thin wrapper around `mosh`
- print concise post-install usage guidance

The new workflow will not:

- create a fake global `mosh` config file layout
- manage host aliases or per-host config files
- modify shell rc files
- open firewall ports or reconfigure remote hosts

## Target Files

- Create: `scripts/install-global-mosh-config`
- Update: `README.md`
- Update: `README.zh-CN.md`

## Script Behavior

`scripts/install-global-mosh-config` should:

1. detect the current OS and supported package manager
2. install `mosh`
3. ensure `~/.local/bin` exists
4. write `~/.local/bin/mosh-connect`
5. mark the wrapper executable
6. print a short summary including the wrapper path and an example command

Supported package managers should match the repository's current install surface:

- macOS: `brew`
- Debian/Ubuntu: `apt-get`
- Arch: `pacman`
- Fedora: `dnf`

Unsupported platforms should fail with a clear error message.

## Wrapper Command Contract

`~/.local/bin/mosh-connect` should:

- fail clearly if `mosh` is not installed or not on `PATH`
- require a destination argument such as `user@host`
- forward all remaining arguments to `mosh`
- print a short help message when no destination is provided

Example:

```bash
mosh-connect user@example.com
mosh-connect user@example.com --ssh='ssh -p 2222'
```

## Documentation Changes

Both README files should gain a short section describing:

- how to run `scripts/install-global-mosh-config`
- where `mosh-connect` is installed
- that the remote host also needs `mosh-server` available, usually by installing `mosh`

## Testing Strategy

Because the repository currently uses shell scripts without a unit-test harness for these global installer helpers, validation will be lightweight and pragmatic:

- run `bash -n scripts/install-global-mosh-config`
- verify the generated wrapper script content is syntactically valid shell
- review README examples for consistency with the implemented command name

If future shell-script coverage expands, this installer can be folded into a dry-run style test path similar to the existing bootstrap checks.
