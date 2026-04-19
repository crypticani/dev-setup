-- Basic Neovim Configuration
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true

-- Leader key
vim.g.mapleader = " "

-- Quick save
vim.keymap.set("n", "<leader>w", ":w<CR>")
-- Quick quit
vim.keymap.set("n", "<leader>q", ":q<CR>")
