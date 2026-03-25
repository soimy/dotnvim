# dotnvim

My Neovim configuration based on [LazyVim](https://www.lazyvim.org/).

[简体中文说明](./README.zh-CN.md)

## Stack

- Neovim
- LazyVim
- Snacks UI
- tmux-friendly terminal workflow

## Requirements

- Neovim `>= 0.11.2`
- `git`
- `ripgrep`
- `fd`
- `fzf`
- `lazygit`
- `tree-sitter` CLI

Supported package managers:

- Homebrew on macOS
- `apt` on Ubuntu/Debian
- `pacman` on Arch
- `dnf` on Fedora

On Ubuntu/Debian, the bootstrap script expects `nvm` at `~/.nvm/nvm.sh`, activates the latest Node.js with `nvm`, clears incompatible npm `prefix` settings from older runs, and uses that runtime for global npm packages such as the `tree-sitter` CLI. This avoids the outdated Node.js versions shipped by `apt`. The Linux bootstrap also installs `unzip`, which Mason needs for some tools such as `stylua`.

Example for macOS:

```bash
brew install neovim fd ripgrep fzf lazygit tree-sitter
```

## Install

Clone directly to the Neovim config path:

```bash
git clone https://github.com/soimy/dotnvim ~/.config/nvim
```

Run the bootstrap script:

```bash
cd ~/.config/nvim
./bootstrap.sh
```

Preview without changing the machine:

```bash
./bootstrap.sh --dry-run
```

Install the standalone `mosh` helper:

```bash
./scripts/install-global-mosh-config
```

Open Neovim and run:

```vim
:checkhealth
```

## Mosh Helper

The standalone installer provisions `mosh`, installs `mosh-connect` to `~/.local/bin/mosh-connect`, and on macOS updates `~/.zshenv` if needed so SSH-launched shells can find Homebrew's `mosh-server`.

Example:

```bash
mosh-connect user@example.com
mosh-connect user@example.com --ssh='ssh -p 2222'
```

The remote host also needs `mosh-server` available, which usually means installing `mosh` on the remote machine too.

## Notes

- This config intentionally uses `Snacks` as the main picker/UI path.
- Ruby and Perl Neovim providers are disabled.
- Some optional image preview features depend on extra system packages and are not required for normal coding workflows.
- `lazygit` is treated as optional on some Linux distributions where the package may not exist in the default repo.

## Agent Notes

This repository is a personal cloud-synced configuration project. For agent-assisted changes:

- prefer direct, pragmatic edits over heavyweight process
- do not require heavy TDD for simple shell, config, or documentation updates
- do not require git worktrees by default; working directly on the current branch is acceptable unless isolation is explicitly requested
- use lightweight verification that matches the scope, such as shell syntax checks, smoke tests, or focused manual verification

## Bazzite / image-based Fedora

For Bazzite and similar `rpm-ostree` / `bootc` systems, it is usually more convenient to run this inside a `distrobox` instead of layering everything onto the host.

Example:

```bash
distrobox create --name dotnvim-fedora --image registry.fedoraproject.org/fedora:43 --yes
distrobox enter dotnvim-fedora
git clone https://github.com/soimy/dotnvim ~/.config/nvim
cd ~/.config/nvim
./bootstrap.sh
```
