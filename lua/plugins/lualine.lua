-- Lualine configuration mirroring the Powerlevel10k (p10k) shell prompt style.
--
-- p10k reference (from ~/.p10k.zsh):
--   Left  line 1 : os_icon | dir | vcs
--   Right line 1 : status | command_execution_time | background_jobs | time
--   Style         : classic powerline, dark bg (236), angled separators, 2-line
--   Colors        : dir fg=31/103/39, git clean=76, modified=178,
--                   untracked=39, conflict=196, time=66, exec-time=248,
--                   status ok=70 (✔), status err=160 (✘)
--   Git icons     : branch=\uF126 ( ), ahead=⇡, behind=⇣, staged=+,
--                   unstaged=!, untracked=?, stash=*, conflict=~

-- Map p10k 256-color indices to hex for lualine theming.
local c = {
  bg        = "#303030", -- xterm-236 (POWERLEVEL9K_BACKGROUND)
  fg_dir    = "#0087af", -- xterm-31  (dir foreground)
  fg_dir_sh = "#8787af", -- xterm-103 (shortened dir)
  fg_anchor = "#00afff", -- xterm-39  (anchor dir / untracked git)
  fg_git_ok = "#5fdf00", -- xterm-76  (clean git / status ok)
  fg_mod    = "#d7af00", -- xterm-178 (modified git)
  fg_conf   = "#df0000", -- xterm-196 (conflicted git / status error)
  fg_time   = "#5f8787", -- xterm-66  (time)
  fg_exec   = "#a8a8a8", -- xterm-248 (exec time)
  fg_ok     = "#5faf00", -- xterm-70  (status ✔)
  fg_err    = "#df0000", -- xterm-160 (status ✘)
  sep       = "#1c1c1c", -- separator contrast colour
}

-- ── helpers ──────────────────────────────────────────────────────────────────

--- Return the p10k-style git status string for the current buffer.
local function git_status()
  -- Rely on gitsigns (bundled by LazyVim) for counts.
  local ok, gs = pcall(require, "gitsigns")
  if not ok then return "" end

  local buf = vim.b.gitsigns_status_dict
  if not buf or not buf.head then return "" end

  local branch = buf.head
  -- Truncate >32 chars: first 12 … last 12  (same logic as p10k)
  if #branch > 32 then
    branch = branch:sub(1, 12) .. "…" .. branch:sub(-12)
  end

  local parts = { " " .. branch } -- \uF126 = 

  local ahead  = buf.ahead  or 0
  local behind = buf.behind or 0
  if behind > 0 then parts[#parts + 1] = "⇣" .. behind end
  if ahead  > 0 then parts[#parts + 1] = "⇡" .. ahead  end

  local staged    = buf.staged    or 0
  local changed   = buf.changed   or 0
  local untracked = buf.untracked or 0
  local conflicts = buf.conflicts or 0

  if staged    > 0 then parts[#parts + 1] = "+" .. staged    end
  if changed   > 0 then parts[#parts + 1] = "!" .. changed   end
  if untracked > 0 then parts[#parts + 1] = "?" .. untracked end
  if conflicts > 0 then parts[#parts + 1] = "~" .. conflicts end

  return table.concat(parts, " ")
end

--- Return a coloured exit-status component (✔ / ✘ / signal).
local function exit_status()
  local code = vim.v.shell_error
  if code == 0 then
    return "%#LualineStatusOk#✔"
  else
    return "%#LualineStatusErr#✘ " .. tostring(code)
  end
end

--- Return the last command execution time (populated by LazyVim extras or set
--- manually via an autocmd). Falls back to empty string.
local function exec_time()
  -- LazyVim / noice stores this in vim.g._last_cmd_time (ms).
  local ms = vim.g._last_cmd_time
  if not ms or ms < 3000 then return "" end -- p10k threshold = 3 s
  local s = math.floor(ms / 1000)
  if s < 60    then return s .. "s"
  elseif s < 3600 then
    return math.floor(s / 60) .. "m " .. (s % 60) .. "s"
  else
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    return h .. "h " .. m .. "m " .. (s % 60) .. "s"
  end
end

--- Background job count (p10k: background_jobs).
local function bg_jobs()
  -- vim.fn.jobcount() counts active terminal/async jobs in Neovim.
  local n = vim.fn.jobcount and vim.fn.jobcount() or 0
  return n > 0 and ("%" .. n) or ""
end

-- ── lualine theme ─────────────────────────────────────────────────────────────
-- Build a minimal theme that reflects p10k's colour palette.
local p10k_theme = {
  normal = {
    a = { fg = c.fg_anchor, bg = c.bg, gui = "bold" },
    b = { fg = c.fg_dir,    bg = c.bg },
    c = { fg = c.fg_time,   bg = c.bg },
  },
  insert  = { a = { fg = c.fg_git_ok, bg = c.bg, gui = "bold" } },
  visual  = { a = { fg = c.fg_mod,    bg = c.bg, gui = "bold" } },
  replace = { a = { fg = c.fg_err,    bg = c.bg, gui = "bold" } },
  command = { a = { fg = c.fg_exec,   bg = c.bg, gui = "bold" } },
  inactive = {
    a = { fg = c.fg_exec, bg = c.bg },
    b = { fg = c.fg_exec, bg = c.bg },
    c = { fg = c.fg_exec, bg = c.bg },
  },
}

-- ── plugin spec ───────────────────────────────────────────────────────────────
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme                = p10k_theme,
      -- Angled powerline separators (matches p10k classic style)
      section_separators   = { left = "", right = "" },
      component_separators = { left = "│", right = "│" },
      globalstatus         = true, -- single statusline (like p10k's full-width bar)
      refresh              = { statusline = 1000 },
    },

    -- ── LEFT side – mirrors p10k left prompt elements ──────────────────────
    -- Line 1:  os_icon | dir | vcs
    sections = {
      lualine_a = {
        -- os_icon: show the Neovim logo (Nerd Font ) as an OS/app marker
        {
          function() return "" end,  -- \uE7C5 = Neovim icon (nerdfont-v3)
          color    = { fg = "#ffffff", bg = c.bg },
          padding  = { left = 1, right = 1 },
        },
      },
      lualine_b = {
        -- dir: current working directory (truncated, anchored at git root)
        {
          "filename",
          path             = 1,       -- relative path
          shorting_target  = 40,
          symbols          = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
          color            = { fg = c.fg_dir, bg = c.bg },
        },
      },
      lualine_c = {
        -- vcs: git branch + status counters in p10k style
        {
          git_status,
          color   = { fg = c.fg_git_ok, bg = c.bg },
          padding = { left = 1, right = 1 },
        },
      },

      -- ── RIGHT side – mirrors p10k right prompt elements ─────────────────
      -- status | command_execution_time | background_jobs | time
      lualine_x = {
        -- background_jobs
        {
          bg_jobs,
          color   = { fg = c.fg_anchor, bg = c.bg },
          padding = { left = 1, right = 1 },
        },
        -- command_execution_time (shown only when ≥ 3 s, like p10k)
        {
          exec_time,
          color   = { fg = c.fg_exec, bg = c.bg },
          padding = { left = 1, right = 1 },
        },
        -- status: exit code of the last shell command
        {
          "diagnostics",
          sources  = { "nvim_lsp", "nvim_diagnostic" },
          sections = { "error", "warn", "info", "hint" },
          symbols  = {
            error = "✘ ",  -- p10k STATUS_ERROR_VISUAL_IDENTIFIER
            warn  = "! ",
            info  = "i ",
            hint  = "» ",
          },
          diagnostics_color = {
            error = { fg = c.fg_err },
            warn  = { fg = c.fg_mod },
            info  = { fg = c.fg_anchor },
            hint  = { fg = c.fg_exec },
          },
          padding = { left = 1, right = 1 },
        },
      },
      lualine_y = {
        -- filetype (compact info, similar to p10k context segment)
        {
          "filetype",
          icon_only = false,
          color     = { fg = c.fg_exec, bg = c.bg },
          padding   = { left = 1, right = 1 },
        },
      },
      lualine_z = {
        -- time: %H:%M:%S (POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}')
        {
          "datetime",
          style = "%H:%M:%S",
          color = { fg = c.fg_time, bg = c.bg },
        },
      },
    },

    -- ── Inactive windows ───────────────────────────────────────────────────
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        { "filename", path = 1, color = { fg = c.fg_exec, bg = c.bg } },
      },
      lualine_x = {
        { "location", color = { fg = c.fg_exec, bg = c.bg } },
      },
      lualine_y = {},
      lualine_z = {},
    },

    -- ── Extensions ─────────────────────────────────────────────────────────
    extensions = { "neo-tree", "lazy", "fugitive", "quickfix", "trouble" },
  },
}
