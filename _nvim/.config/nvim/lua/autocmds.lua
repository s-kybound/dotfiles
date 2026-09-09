local augroup = vim.api.nvim_create_augroup("skybound", { clear = true })

-- Open the file explorer docked to the side when launching on a real file,
-- while leaving the snacks dashboard alone on a bare `nvim`.
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = function()
    local arg = vim.fn.argv(0)
    if arg == "" then
      return -- no argument -> let the dashboard show
    end
    local stat = (vim.uv or vim.loop).fs_stat(arg)
    if stat and stat.type == "directory" then
      return -- neo-tree already hijacks netrw for directories
    end
    -- `show` reveals the sidebar without stealing focus from the file
    vim.cmd("Neotree show")
  end,
})

-- Auto-reload files that change on disk (e.g. edited by an external tool),
-- as long as we aren't in the middle of writing them ourselves.
vim.opt.autoread = true
vim.api.nvim_create_autocmd(
  { "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose", "TermLeave" },
  {
    group = augroup,
    callback = function()
      if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
        vim.cmd("checktime")
      end
    end,
  }
)

-- Let us know when a buffer was reloaded from disk.
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = augroup,
  callback = function()
    vim.notify("File changed on disk — buffer reloaded", vim.log.levels.INFO)
  end,
})

-- Briefly highlight text on yank.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})
