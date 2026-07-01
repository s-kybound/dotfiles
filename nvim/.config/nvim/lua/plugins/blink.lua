-- Modern, fast completion menu. Wires into the LSP via capabilities set in custom_lsp.lua.
return {
  "saghen/blink.cmp",
  version = "1.*",
  event = "InsertEnter",
  opts = {
    keymap = {
      preset = "default",         -- <C-y> accept, <C-n>/<C-p> navigate, <C-e> hide
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      accept = { auto_brackets = { enabled = true } },
      menu = {
        border = "rounded",
        draw = { treesitter = { "lsp" } },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = "rounded" },
      },
      -- copilot.vim already draws inline ghost text, so keep blink's off
      ghost_text = { enabled = false },
    },
    signature = { enabled = true, window = { border = "rounded" } },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
