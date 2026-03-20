# dotnvim

My Neovim configuration based on [LazyVim](https://www.lazyvim.org/).

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

Open Neovim and run:

```vim
:checkhealth
```

## Notes

- This config intentionally uses `Snacks` as the main picker/UI path.
- Ruby and Perl Neovim providers are disabled.
- Some optional image preview features depend on extra system packages and are not required for normal coding workflows.
- `lazygit` is treated as optional on some Linux distributions where the package may not exist in the default repo.

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
