vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.python3_host_prog = vim.fn.exepath("python3")

local node_host = vim.fn.expand("~/.local/lib/node_modules/neovim/bin/cli.js")
if vim.fn.filereadable(node_host) == 1 then
  vim.g.node_host_prog = node_host
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
