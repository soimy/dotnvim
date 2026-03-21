-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<C-h>", "5h", { desc = "Move Left x5" })
vim.keymap.set("n", "<C-j>", "5gj", { desc = "Move Down x5" })
vim.keymap.set("n", "<C-k>", "5gk", { desc = "Move Up x5" })
vim.keymap.set("n", "<C-l>", "5l", { desc = "Move Right x5" })

vim.keymap.set("n", "mm", "gcc", { desc = "Toggle Comment Line", remap = true })

vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit Insert Mode" })
