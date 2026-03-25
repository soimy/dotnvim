local M = {}

local function executable(name)
  return vim.fn.executable(name) == 1
end

local function resolved_mason_tools()
  local tools = vim.deepcopy((LazyVim and LazyVim.opts("mason.nvim").ensure_installed) or {})
  local skipped = {}
  local filtered = {}

  for _, tool in ipairs(tools) do
    if (tool == "csharpier" or tool == "fantomas") and not executable("dotnet") then
      table.insert(skipped, { tool = tool, reason = "dotnet not found" })
    else
      table.insert(filtered, tool)
    end
  end

  return filtered, skipped
end

local function any_package_installing(registry)
  for _, pkg in ipairs(registry.get_all_packages()) do
    if pkg:is_installing() then
      return true
    end
  end
  return false
end

function M.mason_sync(timeout_ms)
  local ok, mr = pcall(require, "mason-registry")
  if not ok then
    return
  end

  local tools, skipped = resolved_mason_tools()
  local refreshed = false
  local failed = {}

  mr.refresh(function()
    refreshed = true
    for _, tool in ipairs(tools) do
      local pkg = mr.get_package(tool)
      if not pkg:is_installed() then
        pkg:once("install:failed", function()
          failed[tool] = true
        end)
        if not pkg:is_installing() then
          pkg:install()
        end
      end
    end
  end)

  local ok_wait = vim.wait(timeout_ms or 600000, function()
    if not refreshed then
      return false
    end
    if any_package_installing(mr) then
      return false
    end
    for _, tool in ipairs(tools) do
      local pkg = mr.get_package(tool)
      if not pkg:is_installed() and not failed[tool] then
        return false
      end
    end
    return true
  end, 1000)

  if not ok_wait then
    error("Timed out waiting for Mason tools to install")
  end

  if next(failed) then
    local failed_tools = vim.tbl_keys(failed)
    table.sort(failed_tools)
    print("[dotnvim] Mason tools failed: " .. table.concat(failed_tools, ", "))
  end

  if #skipped > 0 then
    table.sort(skipped, function(a, b)
      return a.tool < b.tool
    end)
    local labels = {}
    for _, item in ipairs(skipped) do
      table.insert(labels, string.format("%s (%s)", item.tool, item.reason))
    end
    print("[dotnvim] Mason tools skipped: " .. table.concat(labels, ", "))
  end
end

return M
