return {
  "xiyaowong/nvim-transparent",
  config = function()
    require("transparent").setup({
      extra_groups = { "NvimTreeNormal", "NvimTreeVertSplit", "NvimTreeEndOfBuffer", "NotifyBackground" },
    })
    require("notify").setup({
      background_colour = "#00000000",
    })
  end,
}
