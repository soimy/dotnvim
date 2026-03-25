return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      if vim.fn.executable("dotnet") ~= 1 and opts.servers.fsautocomplete then
        opts.servers.fsautocomplete.enabled = false
      end
    end,
  },
}
