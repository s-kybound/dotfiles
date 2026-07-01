return {
  "rose-pine/neovim",
  name = "rose-pine",
  lazy = false,
  priority = 1000, -- load before everything else so other plugins see the colors
  config = function()
    require("rose-pine").setup({
      variant = "moon",
      dark_variant = "moon",
      styles = {
        bold = true,
        italic = true,
        transparency = false,
      },
    })
    vim.cmd.colorscheme("rose-pine")
  end,
}
