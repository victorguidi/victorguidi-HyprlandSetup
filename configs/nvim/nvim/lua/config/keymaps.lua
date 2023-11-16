-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<Leader>m", ":lua require('harpoon.mark').add_file()<CR>", { noremap = true, silent = true })
vim.keymap.set(
  "n",
  "<Leader>h",
  ":lua require('harpoon.ui').toggle_quick_menu()<CR>",
  { noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<Leader>1",
  ":lua require('harpoon.ui').nav_file(1)<CR>",
  { desc = "go to position 1 in harpoon", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<Leader>2",
  ":lua require('harpoon.ui').nav_file(2)<CR>",
  { desc = "go to position 2 in harpoon", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<Leader>3",
  ":lua require('harpoon.ui').nav_file(3)<CR>",
  { desc = "go to position 3 in harpoon", noremap = true, silent = true }
)

vim.keymap.set("n", "<Leader>wh", "<C-w>h", { desc = "Go to left window", remap = true })
vim.keymap.set("n", "<Leader>wj", "<C-w>j", { desc = "Go to lower window", remap = true })
vim.keymap.set("n", "<Leader>wk", "<C-w>k", { desc = "Go to upper window", remap = true })
vim.keymap.set("n", "<Leader>wl", "<C-w>l", { desc = "Go to right window", remap = true })
