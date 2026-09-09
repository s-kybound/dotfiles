-- General keymaps. Plugin-specific maps live in their own plugin specs.
local map = vim.keymap.set

-- clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- save / quit
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })

-- window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- buffer navigation (barbar)
map("n", "<S-h>", "<cmd>BufferPrevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>BufferNext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>BufferClose<cr>", { desc = "Close buffer" })
map("n", "<leader>bp", "<cmd>BufferPick<cr>", { desc = "Pick buffer" })

-- move selected lines up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- keep cursor centered while jumping around
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
