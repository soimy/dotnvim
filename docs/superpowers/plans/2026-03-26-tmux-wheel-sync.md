# Tmux Wheel Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sync the latest local tmux wheel behavior into the repository's automatic global tmux deployment flow and verify the generated config contains those bindings.

**Architecture:** Treat the installer output as the contract. First add a shell smoke test that installs into a temporary home directory and fails until the expected wheel bindings appear. Then update the global template and the repository tmux config with the same wheel behavior and rerun verification.

**Tech Stack:** Bash, tmux config templates, shell smoke tests, Markdown docs

---

### Task 1: Installer Smoke Test

**Files:**
- Create: `tests/install-global-tmux-config.sh`

- [ ] **Step 1: Write the failing test**
- [ ] **Step 2: Run `bash tests/install-global-tmux-config.sh` and confirm it fails because the wheel bindings are not yet present in the generated config**
- [ ] **Step 3: Keep the fixture network-free by stubbing `git clone` and the TPM install hook**

### Task 2: Sync Tmux Configs

**Files:**
- Modify: `tmux/global.tmux.conf.template`
- Modify: `tmux/tmux.conf`

- [ ] **Step 1: Copy the wheel bindings from the current local global tmux config into the deployment template**
- [ ] **Step 2: Mirror the same bindings into `tmux/tmux.conf` so the repository configs do not drift**
- [ ] **Step 3: Keep all unrelated tmux settings unchanged**

### Task 3: Verify

**Files:**
- Test: `tests/install-global-tmux-config.sh`

- [ ] **Step 1: Re-run `bash tests/install-global-tmux-config.sh` and confirm it passes**
- [ ] **Step 2: Run `bash -n scripts/install-global-tmux-config tests/install-global-tmux-config.sh`**
- [ ] **Step 3: Review `git diff --stat` to confirm the change stayed scoped to tmux wheel sync work**
