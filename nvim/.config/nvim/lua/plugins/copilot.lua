return {
  "github/copilot.vim",
  lazy = false,
  init = function()
    -- free up <Tab> for the blink.cmp completion menu
    vim.g.copilot_no_tab_map = true
  end,
  config = function()
    -- accept the inline copilot suggestion with <C-l>
    vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
      desc = "Copilot Accept",
    })
  end,
}
