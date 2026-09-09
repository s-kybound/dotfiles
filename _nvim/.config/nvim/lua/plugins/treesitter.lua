return {
      "nvim-treesitter/nvim-treesitter", 
      branch = 'master', 
      event = { "BufReadPost", "BufNewFile" },
      lazy = false, 
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({

          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },

          indent = {
            enable = true,
          },
        })
      end
}
