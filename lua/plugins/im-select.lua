return {
  {
    "keaising/im-select.nvim",
    event = "VeryLazy",
    opts = {
      default_im_select = "com.apple.keylayout.ABC",
      default_command = (function()
        local candidates = {
          "/opt/homebrew/bin/macism",
          "/usr/local/bin/macism",
          "macism",
          "/opt/homebrew/bin/im-select",
          "/usr/local/bin/im-select",
          "im-select",
        }

        for _, candidate in ipairs(candidates) do
          if vim.fn.executable(candidate) == 1 then
            return candidate
          end
        end

        return "/opt/homebrew/bin/macism"
      end)(),
      set_default_events = { "InsertLeave", "CmdlineLeave", "FocusGained" },
      set_previous_events = { "InsertEnter" },
      keep_quiet_on_no_binary = false,
      async_switch_im = true,
    },
    config = function(_, opts)
      require("im_select").setup(opts)
    end,
  },
}
