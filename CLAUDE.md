# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A personal Neovim configuration built on [LazyVim](https://www.lazyvim.org/) v8, using Lua throughout. The repo also contains a `bootstrap.sh` that installs system dependencies and syncs all plugins/Mason tools headlessly.

## Key Commands

### Setup
```bash
./bootstrap.sh              # Install system deps, providers, and sync all plugins
./bootstrap.sh --dry-run    # Preview all commands without executing
```

After bootstrap, run `:checkhealth` inside Neovim to verify.

### Tests
```bash
bash tests/bootstrap-dry-run.sh   # Smoke test: runs bootstrap with stubbed binaries, asserts exit 0
```

### Formatting
```bash
stylua lua/    # Format Lua files (2-space indent, 120 col width — see stylua.toml)
```

## Architecture

### Startup Flow
```
init.lua
  → config/lazy.lua          # bootstraps lazy.nvim, then calls lazy.setup()
      → LazyVim core         # base framework
      → lazyvim extras       # from lazyvim.json
      → lua/plugins/         # custom overrides/additions
```

`init.lua` disables Ruby and Perl providers intentionally, and hardwires Python3 and Node providers.

### Custom Lua Modules (`lua/config/`)
| File | Purpose |
|---|---|
| `lazy.lua` | Bootstraps lazy.nvim and calls `lazy.setup()` |
| `options.lua` | Sets `lazyvim_picker = "snacks"` (only meaningful override) |
| `keymaps.lua` | `Ctrl+hjkl` = 5-step motion, `mm` = toggle comment, `jj` = Esc |
| `autocmds.lua` | Disables spell for markdown/mdx |
| `bootstrap.lua` | Exposes `mason_sync()` called headlessly by `bootstrap.sh` |

### Custom Plugins (`lua/plugins/`)
| File | Purpose |
|---|---|
| `colorscheme.lua` | Configures `kanagawa-dragon` as the default colorscheme and tweaks core highlights |
| `lsp.lua` | Enables built-in LSP inlay hints globally |
| `neo-tree.lua` | Explicitly disables neo-tree in favor of Snacks explorer |
| `lualine.lua` | Custom statusline inspired by Powerlevel10k |
| `snacks.lua` | Configures snacks.nvim as primary picker/UI, startup explorer, and dashboard behavior; **explicitly disables noice.nvim** |
| `spellcheck.lua` | Wires two non-Mason LSP servers: ltex-ls-plus (grammar/Chinese) and cspell-lsp (comment/identifier spelling) |

### Local Tools (`.tools/`)
- **`.tools/ltex/ltex-ls-plus-18.6.1/`** — pre-installed binary; path is hardcoded in `spellcheck.lua`
- **`.tools/cspell-lsp/`** — npm package (`@vlabo/cspell-lsp`); needs `npm install` inside that directory

### Install Scripts (`scripts/install/`)
`bootstrap.sh` detects the OS and delegates to one of: `macos.sh`, `apt.sh`, `pacman.sh`, or `dnf.sh`. Shared helpers live in `common.sh`.

## Important Behaviors & Gotchas

- **Snacks is the sole picker/explorer**: `fzf` extra is loaded via LazyVim but snacks overrides the picker globally, and explorer behavior is handled by `snacks_explorer`.
- **noice.nvim is disabled**: explicitly set in `snacks.lua`.
- **Default colorscheme is `kanagawa-dragon`** with a custom `LspInlayHint` background for readability.
- **ltex-ls-plus path is hardcoded**: `.tools/ltex/ltex-ls-plus-18.6.1/bin/ltex-ls-plus` — update `spellcheck.lua` if the version changes.
- **lazygit is optional** on apt/dnf systems; bootstrap won't fail without it.
- **dotnet tools** (csharpier, fantomas) emit Mason warnings if `dotnet` is absent — expected.
- **Bazzite/rpm-ostree**: run inside a distrobox Fedora 43 container.
- Ruby and Perl providers are intentionally disabled in `init.lua`.

## LazyVim Extras Enabled

See `lazyvim.json`: `ai.copilot`, `coding.yanky`, `editor.fzf`, `lang.dotnet`, `lang.git`, `lang.json`, `lang.markdown`, `lang.python`, `lang.toml`, `lang.typescript`, `util.gh`, `util.gitui`.
