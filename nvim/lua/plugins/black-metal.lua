return {
  {
    "metalelf0/black-metal-theme-neovim",
    lazy = false,
    priority = 1000,
    opts = {
      theme = "darkthrone",
      variant = "dark",
      transparent = false,
      term_colors = true,
    },
    config = function(_, opts)
      require("black-metal").setup(opts)
      require("black-metal").load()
    end,
  },
}
