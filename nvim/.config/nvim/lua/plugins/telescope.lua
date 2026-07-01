return {
  "nvim-telescope/telescope.nvim",
  tag = "v0.2.0",
  cmd = "Telescope",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
  },
  opts = {
    defaults = {
      prompt_prefix = "   ",
      selection_caret = "  ",
      entry_prefix = "  ",
      sorting_strategy = "ascending",
      path_display = { "truncate" },
      layout_config = {
        prompt_position = "top",
        horizontal = { preview_width = 0.55 },
        width = 0.87,
        height = 0.80,
      },
    },
  },
}
