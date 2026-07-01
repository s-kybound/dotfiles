-- Popup that shows available keybindings as you type a leader sequence.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    spec = {
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "<leader>b", group = "Buffer" },
      { "<leader>c", group = "Code" },
    },
  },
}
