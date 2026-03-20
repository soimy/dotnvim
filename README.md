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

Recommended on macOS:

```bash
brew install neovim fd ripgrep fzf tmux lazygit tree-sitter
```

## Install

Clone directly to the Neovim config path:

```bash
git clone https://github.com/soimy/dotnvim ~/.config/nvim
```

Then install runtime dependencies:

```bash
npm config set prefix ~/.local
npm install -g neovim @mermaid-js/mermaid-cli
python3 -m pip install --user --break-system-packages --upgrade pynvim
```

Sync plugins:

```bash
nvim --headless '+Lazy! sync' '+qa'
```

Open Neovim and run:

```vim
:checkhealth
```

## Notes

- This config intentionally uses `Snacks` as the main picker/UI path.
- Ruby and Perl Neovim providers are disabled.
- Some optional image preview features depend on extra system packages and are not required for normal coding workflows.
