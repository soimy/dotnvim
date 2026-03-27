local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "git-worktree" })
end

local function parse_worktree_line(line)
  local path, sha, branch = line:match("^(%S+)%s+(%S+)%s+(.+)$")
  if not path or not sha or not branch or sha == "(bare)" then
    return nil
  end

  return {
    path = path,
    sha = sha,
    branch = branch:gsub("^%[", ""):gsub("%]$", ""),
  }
end

local function list_worktrees()
  local lines = vim.fn.systemlist({ "git", "worktree", "list" })
  if vim.v.shell_error ~= 0 then
    notify("Current directory is not a git worktree", vim.log.levels.WARN)
    return {}
  end

  local worktrees = {}
  for _, line in ipairs(lines) do
    local worktree = parse_worktree_line(line)
    if worktree then
      table.insert(worktrees, worktree)
    end
  end
  return worktrees
end

local function switch_worktree()
  local worktrees = list_worktrees()
  if #worktrees == 0 then
    notify("No worktrees found", vim.log.levels.WARN)
    return
  end

  vim.ui.select(worktrees, {
    prompt = "Switch Git Worktree",
    format_item = function(item)
      return string.format("%-24s %s", item.branch, item.path)
    end,
  }, function(choice)
    if not choice then
      return
    end
    require("git-worktree").switch_worktree(choice.path)
  end)
end

local function create_worktree()
  local repo_name = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
  vim.ui.input({ prompt = "Worktree path: ", default = "../" .. repo_name .. "-" }, function(path)
    if not path or vim.trim(path) == "" then
      return
    end

    vim.ui.input({ prompt = "Branch (empty = detached): " }, function(branch)
      if branch == nil then
        return
      end
      require("git-worktree").create_worktree(path, vim.trim(branch), nil)
    end)
  end)
end

return {
  {
    "polarmutex/git-worktree.nvim",
    version = "^2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gw", switch_worktree, desc = "Worktree Switch" },
      { "<leader>gW", create_worktree, desc = "Worktree Create" },
    },
    config = function()
      local hooks = require("git-worktree.hooks")
      hooks.register(hooks.type.SWITCH, hooks.builtins.update_current_buffer_on_switch)
    end,
  },
}
