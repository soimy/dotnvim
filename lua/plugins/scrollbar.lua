return {
  {
    "kevinhwang91/nvim-hlslens",
    event = "LazyFile",
    opts = {
      calm_down = true,
      nearest_only = true,
    },
    keys = {
      {
        "n",
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        mode = { "n", "x" },
        desc = "Next Search Result",
      },
      {
        "N",
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        mode = { "n", "x" },
        desc = "Prev Search Result",
      },
      {
        "*",
        [[*<Cmd>lua require('hlslens').start()<CR>]],
        mode = "n",
        desc = "Search Word Forward",
      },
      {
        "#",
        [[#<Cmd>lua require('hlslens').start()<CR>]],
        mode = "n",
        desc = "Search Word Backward",
      },
      {
        "g*",
        [[g*<Cmd>lua require('hlslens').start()<CR>]],
        mode = "n",
        desc = "Search Partial Word Forward",
      },
      {
        "g#",
        [[g#<Cmd>lua require('hlslens').start()<CR>]],
        mode = "n",
        desc = "Search Partial Word Backward",
      },
    },
  },
  {
    "petertriho/nvim-scrollbar",
    event = "LazyFile",
    dependencies = {
      "kevinhwang91/nvim-hlslens",
    },
    opts = {
      show = true,
      show_in_active_only = false,
      set_highlights = true,
      handle = {
        text = " ",
        color = "#6a7a92",
        blend = 20,
      },
      marks = {
        Cursor = {
          text = " ",
          priority = 100,
        },
        Search = {
          text = { "-", "=" },
          priority = 90,
        },
        Error = {
          text = { "-", "=" },
          priority = 80,
        },
        Warn = {
          text = { "-", "=" },
          priority = 70,
        },
        Info = {
          text = { "-", "=" },
          priority = 60,
        },
        Hint = {
          text = { "-", "=" },
          priority = 50,
        },
        Misc = {
          text = { "-", "=" },
          priority = 40,
        },
        GitAdd = {
          text = "┆",
          priority = 30,
        },
        GitChange = {
          text = "┆",
          priority = 20,
        },
        GitDelete = {
          text = "▁",
          priority = 10,
        },
      },
      excluded_buftypes = {
        "nofile",
        "prompt",
        "terminal",
      },
      excluded_filetypes = {
        "snacks_dashboard",
        "snacks_picker_input",
        "snacks_picker_list",
        "snacks_picker_preview",
      },
    },
    config = function(_, opts)
      local scrollbar = require("scrollbar")
      scrollbar.setup(opts)

      local ok_hlslens = pcall(require, "hlslens")
      local ok_search, search = pcall(require, "scrollbar.handlers.search")
      if ok_hlslens and ok_search then
        search.setup()
      end

      local ok_diag, diag = pcall(require, "scrollbar.handlers.diagnostic")
      if ok_diag then
        diag.setup()
      end

      local ok_git, gitsigns = pcall(require, "scrollbar.handlers.gitsigns")
      if ok_git then
        gitsigns.setup()
      end
    end,
  },
}
