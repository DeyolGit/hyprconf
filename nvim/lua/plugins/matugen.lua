
return {
  {
    "Z-F-x/vscode_modern_theme_transparent.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function()
      require("vscode_modern_theme_transparent").setup({
        cursorline = true,
        transparent_background = true,
        nvim_tree_darker = true,
      })

      vim.cmd.colorscheme("vscode_modern_theme_transparent")

      -- Let your terminal background show through
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
  },
}

