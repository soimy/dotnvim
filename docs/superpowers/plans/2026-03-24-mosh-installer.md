# Mosh Installer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a standalone `mosh` installer script that installs the package locally, provisions `~/.local/bin/mosh-connect`, and documents how to use it.

**Architecture:** Keep `mosh` outside `bootstrap.sh` and model the installer after the existing standalone tmux deployment helper. Use a shell smoke test to validate package-manager selection and wrapper generation, then implement the minimal script and README updates needed to satisfy that test.

**Tech Stack:** Bash, existing `scripts/install/common.sh` helpers, shell smoke tests, Markdown docs

---

### Task 1: Installer Smoke Test

**Files:**
- Create: `tests/install-global-mosh-config.sh`

- [ ] **Step 1: Write the failing test**
- [ ] **Step 2: Run the test to verify it fails because the installer script does not exist yet**
- [ ] **Step 3: Keep the test fixture focused on package install stubs and generated wrapper assertions**

### Task 2: Standalone Installer

**Files:**
- Create: `scripts/install-global-mosh-config`

- [ ] **Step 1: Implement OS/package-manager detection and `mosh` installation**
- [ ] **Step 2: Generate `~/.local/bin/mosh-connect` with clear usage/help output**
- [ ] **Step 3: Re-run the smoke test and shell syntax checks**

### Task 3: Documentation

**Files:**
- Modify: `README.md`
- Modify: `README.zh-CN.md`

- [ ] **Step 1: Add a short `mosh` installer section in both READMEs**
- [ ] **Step 2: Re-run the smoke test and shell syntax checks after docs changes**
- [ ] **Step 3: Commit only the new plan, test, installer, and README changes**
