local M = {}

function M.mason_sync(timeout_ms)
  local ok, mr = pcall(require, "mason-registry")
  if not ok then
    return
  end

  local plugin = require("lazy.core.config").plugins["mason.nvim"]
  local tools = vim.tbl_get(plugin, "opts", "ensure_installed") or {}
  local refreshed = false

  mr.refresh(function()
    refreshed = true
    for _, tool in ipairs(tools) do
      local pkg = mr.get_package(tool)
      if not pkg:is_installed() and not pkg:is_installing() then
        pkg:install()
      end
    end
  end)

  local ok_wait = vim.wait(timeout_ms or 600000, function()
    if not refreshed then
      return false
    end
    for _, tool in ipairs(tools) do
      local pkg = mr.get_package(tool)
      if not pkg:is_installed() then
        return false
      end
    end
    return true
  end, 1000)

  if not ok_wait then
    error("Timed out waiting for Mason tools to install")
  end
end

return M
