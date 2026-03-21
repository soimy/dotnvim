return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local config_dir = vim.fn.stdpath("config")
      opts.servers = opts.servers or {}

      opts.servers.ltex_plus = {
        cmd = { config_dir .. "/.tools/ltex/ltex-ls-plus-18.6.1/bin/ltex-ls-plus" },
        filetypes = {
          "gitcommit",
          "markdown",
          "text",
        },
        mason = false,
        settings = {
          ltex = {
            language = "zh-CN",
            enabled = {
              "gitcommit",
              "markdown",
              "text",
            },
          },
        },
      }

      opts.servers.cspell_ls = {
        cmd = { config_dir .. "/.tools/cspell-lsp/node_modules/.bin/cspell-lsp", "--stdio" },
        filetypes = {
          "bash",
          "c",
          "cmake",
          "cpp",
          "css",
          "dockerfile",
          "go",
          "html",
          "java",
          "javascript",
          "javascriptreact",
          "jsonc",
          "lua",
          "python",
          "rust",
          "scss",
          "sh",
          "sql",
          "toml",
          "typescript",
          "typescriptreact",
          "vim",
          "xml",
          "yaml",
          "zsh",
        },
        mason = false,
      }
    end,
  },
}
