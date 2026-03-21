return {
  {
    "keaising/im-select.nvim",
    event = "VeryLazy",
    opts = {
      default_im_select = "com.apple.keylayout.ABC",
      default_command = "/opt/homebrew/bin/macism",
      set_default_events = { "InsertLeave", "CmdlineLeave", "FocusGained" },
      set_previous_events = { "InsertEnter" },
      keep_quiet_on_no_binary = true,
      async_switch_im = true,
    },
    config = function(_, opts)
      require("im_select").setup(opts)
    end,
  },
}
