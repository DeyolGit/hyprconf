return {
  {
    "echasnovski/mini.nvim",
    version = false,
    priority = 1000,
    config = function()
      require("mini.base16").setup({
        palette = {
          base00 = "#0b0b0b", -- Main background
          base01 = "#151515", -- Darker panels
          base02 = "#222222", -- Selection background
          base03 = "#454545", -- Comments / inactive text
          base04 = "#777777", -- Muted foreground
          base05 = "#c4c4c4", -- Main text
          base06 = "#e0e0e0", -- Bright text
          base07 = "#f5f5f5", -- Maximum contrast

          base08 = "#d0d0d0", -- Variables
          base09 = "#a8a8a8", -- Numbers
          base0A = "#eeeeee", -- Functions
          base0B = "#bdbdbd", -- Strings
          base0C = "#929292", -- Special characters
          base0D = "#d8d8d8", -- Keywords / types
          base0E = "#aaaaaa", -- Statements
          base0F = "#686868", -- Deprecated / unusual
        },
      })

      vim.cmd.colorscheme("minischeme")

      local set = vim.api.nvim_set_hl

      -- Subtle UI contrast
      set(0, "Normal", { fg = "#c4c4c4", bg = "#0b0b0b" })
      set(0, "NormalFloat", { fg = "#c4c4c4", bg = "#151515" })
      set(0, "FloatBorder", { fg = "#454545", bg = "#151515" })
      set(0, "CursorLine", { bg = "#151515" })
      set(0, "LineNr", { fg = "#454545" })
      set(0, "CursorLineNr", { fg = "#eeeeee", bold = true })
      set(0, "Visual", { bg = "#303030" })
      set(0, "Search", { fg = "#0b0b0b", bg = "#eeeeee" })
      set(0, "IncSearch", { fg = "#0b0b0b", bg = "#bdbdbd" })
      set(0, "StatusLine", { fg = "#c4c4c4", bg = "#151515" })
      set(0, "WinSeparator", { fg = "#303030" })
      set(0, "Pmenu", { fg = "#c4c4c4", bg = "#151515" })
      set(0, "PmenuSel", { fg = "#eeeeee", bg = "#303030", bold = true })
      set(0, "MatchParen", { fg = "#ffffff", bg = "#303030", bold = true })
      set(0, "Comment", { fg = "#686868", italic = true })

      -- Keep diagnostics monochrome, distinguishable by style
      set(0, "DiagnosticError", { fg = "#eeeeee", undercurl = true })
      set(0, "DiagnosticWarn", { fg = "#bdbdbd", underline = true })
      set(0, "DiagnosticInfo", { fg = "#999999" })
      set(0, "DiagnosticHint", { fg = "#777777", italic = true })
    end,
  },
}
