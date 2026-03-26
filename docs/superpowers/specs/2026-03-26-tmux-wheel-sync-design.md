# Tmux Wheel Sync Design

**Date:** 2026-03-26

## Goal

Sync the latest local tmux wheel behavior into this repository's automatic global tmux deployment path so fresh installs generate the same scroll experience as the current machine.

## Scope

This change will:

- update the global tmux config template used by `scripts/install-global-tmux-config`
- keep the repository's checked-in `tmux/tmux.conf` aligned with the same wheel bindings
- add a lightweight smoke test that verifies the generated config includes the required wheel bindings

This change will not:

- refactor the tmux config layout into shared fragments
- change unrelated tmux keybindings, plugins, or theme settings
- introduce a broader shell test harness beyond the installer smoke check

## Target Files

- Update: `tmux/global.tmux.conf.template`
- Update: `tmux/tmux.conf`
- Create: `tests/install-global-tmux-config.sh`

## Behavior To Preserve

The generated global tmux config should match the local wheel behavior now in use:

- scrolling up in the root table should select the pane, enter `copy-mode -e`, and forward the wheel event when the pane is not in alternate screen mode
- scrolling up or down in alternate screen mode should keep forwarding wheel events to the application via `send-keys -M`
- both `copy-mode` and `copy-mode-vi` should scroll by exactly one line per wheel event

## Testing Strategy

Use a shell smoke test around `scripts/install-global-tmux-config` with a temporary `HOME` and stubbed `git` command so the test can run without network access. The test should verify that the installed `~/.config/tmux/tmux.conf` contains the expected wheel bindings, which proves the template and install script work together.
