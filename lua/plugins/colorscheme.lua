return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {
      theme = "dragon",
      compile = false,
      undercurl = true,
      commentStyle = { italic = false },
      keywordStyle = { italic = false },
      statementStyle = { bold = false },
      transparent = false,
      dimInactive = false,
      terminalColors = true,
      overrides = function(colors)
        local theme = colors.theme
        local palette = colors.palette

        return {
          Normal = { bg = theme.ui.bg, fg = theme.ui.fg },
          NormalNC = { bg = theme.ui.bg, fg = theme.ui.fg_dim },
          SignColumn = { bg = theme.ui.bg },
          EndOfBuffer = { bg = theme.ui.bg, fg = theme.ui.bg },
          CursorLine = { bg = theme.ui.bg_m1 },
          CursorLineNr = { fg = palette.carpYellow, bold = true },
          WinSeparator = { fg = theme.ui.special },
          StatusLine = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          StatusLineNC = { bg = theme.ui.bg_m3, fg = theme.ui.nontext },
          Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
          PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
          LspInlayHint = { fg = palette.fujiGray, bg = "#1a1a1a", blend = 10, italic = false },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa-dragon",
    },
  },
}
