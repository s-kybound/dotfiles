-- skybound neovim setup

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "number"

-- syntax highlighting (usually on by default in nvim)
vim.cmd.syntax("on")

-- indents
vim.opt.autoindent = true
vim.opt.copyindent = true

-- file helpers
vim.cmd("filetype plugin indent on")

vim.opt.colorcolumn = "121"

-- search
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- scrolling
vim.opt.scrolloff = 5

-- clipboard
vim.opt.clipboard = "unnamedplus"

-- wildmenu
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

