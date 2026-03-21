local function open_dashboard_new_file()
  vim.cmd("enew")
  vim.schedule(function()
    if vim.bo.buftype == "" then
      vim.bo.modifiable = true
      vim.bo.readonly = false
      vim.cmd("startinsert")
    end
  end)
end

return {
  {
    "folke/noice.nvim",
    enabled = false,
  },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.explorer = vim.tbl_deep_extend("force", opts.explorer or {}, {
        replace_netrw = true,
      })

      opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
        enabled = true,
        ui_select = true,
        sources = vim.tbl_deep_extend("force", (opts.picker or {}).sources or {}, {
          explorer = {
            follow_file = true,
            hidden = true,
            ignored = true,
            auto_close = false,
            layout = { preset = "sidebar", preview = false },
          },
        }),
      })

      local dashboard = opts.dashboard or {}
      local preset = dashboard.preset or {}
      local keys = vim.deepcopy(preset.keys or {})

      for _, item in ipairs(keys) do
        if item.key == "n" then
          item.action = open_dashboard_new_file
        end
      end

      dashboard.preset = vim.tbl_deep_extend("force", preset, { keys = keys })
      opts.dashboard = dashboard
    end,
    config = function(_, opts)
      local snacks = require("snacks")
      snacks.setup(opts)
      require("snacks.image").meta.health = false
    end,
    init = function()
      local group = vim.api.nvim_create_augroup("user_snacks_fixups", { clear = true })
      vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        once = true,
        callback = function()
          local snacks = require("snacks")

          if snacks.config.input.enabled and vim.ui.input ~= snacks.input.input then
            snacks.input.enable()
          end

          if snacks.config.picker.enabled then
            snacks.picker.setup()
          end

          if snacks.config.notifier.enabled and vim.notify ~= snacks.notifier.notify then
            vim.notify = snacks.notifier.notify
          end

          if snacks.config.dashboard.enabled then
            local dashboard = require("snacks.dashboard")
            if not dashboard.status.did_setup then
              dashboard.setup()
            end
          end

          local argv = vim.fn.argv()
          if vim.fn.argc() == 1 and argv[1] == "-" then
            return
          end

          if vim.fn.argc() > 0 then
            local first = argv[1]
            if first and first ~= "" then
              local stat = (vim.uv or vim.loop).fs_stat(first)
              if stat and stat.type == "directory" then
                return
              end
            end
          end

          vim.schedule(function()
            local explorers = snacks.picker.get({ source = "explorer" })
            if explorers and explorers[1] then
              return
            end
            snacks.explorer({ cwd = LazyVim.root() })
          end)

          if not vim.g.user_dashboard_paste_fix then
            vim.g.user_dashboard_paste_fix = true
            local original_paste = vim.paste
            vim.paste = function(lines, phase)
              if vim.bo.filetype == "snacks_dashboard" and not vim.bo.modifiable then
                open_dashboard_new_file()
              end
              return original_paste(lines, phase)
            end
          end
        end,
      })
    end,
  },
}
