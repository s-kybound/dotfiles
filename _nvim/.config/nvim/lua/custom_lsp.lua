-- Advertise blink.cmp's completion capabilities to every language server.
local ok, blink = pcall(require, "blink.cmp")
local capabilities = ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()
vim.lsp.config("*", { capabilities = capabilities })

-- QML language server
vim.lsp.config("qmlls", {
    cmd = { "qmlls", "-E" },
})
vim.lsp.enable("qmlls")

-- Prettier diagnostics
vim.diagnostic.config({
    virtual_text = { prefix = "●", spacing = 2 },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
        },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded", source = true },
})

-- LSP keymaps, set only once a server attaches to a buffer.
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP keymaps",
    callback = function(event)
        local function map(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("gd", "<cmd>Telescope lsp_definitions<cr>", "Goto Definition")
        map("gr", "<cmd>Telescope lsp_references<cr>", "Goto References")
        map("gI", "<cmd>Telescope lsp_implementations<cr>", "Goto Implementation")
        map("gD", vim.lsp.buf.declaration, "Goto Declaration")
        map("K", vim.lsp.buf.hover, "Hover Docs")
        map("<leader>cr", vim.lsp.buf.rename, "Rename")
        map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
        map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev Diagnostic")
        map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next Diagnostic")
    end,
})
