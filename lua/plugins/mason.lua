return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      if vim.fn.executable("dotnet") == 1 then
        return
      end

      opts.ensure_installed = vim.tbl_filter(function(tool)
        return tool ~= "csharpier" and tool ~= "fantomas"
      end, opts.ensure_installed)
    end,
  },
}
