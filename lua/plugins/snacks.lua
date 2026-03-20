return {
  {
    "folke/noice.nvim",
    enabled = false,
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        enabled = true,
        ui_select = true,
      },
    },
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
        end,
      })
    end,
  },
}
