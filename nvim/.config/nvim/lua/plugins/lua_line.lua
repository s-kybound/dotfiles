return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  opts = {
    options = {
      theme = "rose-pine",
      globalstatus = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = { statusline = { "dashboard", "neo-tree", "snacks_dashboard" } },
    },
    sections = {
      lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { "searchcount", "encoding", { "fileformat", icons_enabled = false }, "filetype" },
      lualine_y = { "progress" },
      lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
    },
    inactive_sections = {
      lualine_c = { "%f %y %m" },
      lualine_x = {},
    },
  },
}
