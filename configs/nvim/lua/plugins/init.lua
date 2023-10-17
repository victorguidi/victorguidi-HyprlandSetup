return {
  "ThePrimeagen/harpoon",
  { "mg979/vim-visual-multi", enabled = true },
  {
    "EdenEast/nightfox.nvim",
    priority = 1000, -- make sure to load this before all
    config = function()
      vim.cmd([[colorscheme terafox]])
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    enabled = false,
  },
  {
    "nvimdev/dashboard-nvim",
    enabled = false,
  },
  { "folke/noice.nvim", enabled = false },
}
