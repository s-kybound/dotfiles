-- skybound neovim setup

local opt = vim.opt

-- true color (required for modern colorschemes)
opt.termguicolors = true

-- line numbers
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

-- syntax highlighting (treesitter handles most of it, this is a fallback)
vim.cmd.syntax("on")

-- indents
opt.autoindent = true
opt.copyindent = true
opt.breakindent = true
opt.smartindent = true

-- file helpers
vim.cmd("filetype plugin indent on")

opt.colorcolumn = "121"

-- search
opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

-- scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- clipboard
opt.clipboard = "unnamedplus"

-- splits
opt.splitright = true
opt.splitbelow = true

-- persistent undo, no swap clutter
opt.undofile = true
opt.swapfile = false

-- ui niceties
opt.showmode = false          -- lualine already shows the mode
opt.mouse = "a"
opt.pumheight = 12            -- max items in completion popup
opt.pumblend = 10            -- slight transparency on popups
opt.confirm = true
opt.timeoutlen = 300          -- snappier which-key popup
opt.updatetime = 200

-- wildmenu
opt.wildmenu = true
opt.wildmode = "longest:full,full"
