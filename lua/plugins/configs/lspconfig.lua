-- Global mappings.
-- vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "lsp declaration" })
        vim.keymap.set("n", "gd", function()
            require("telescope.builtin").lsp_definitions({ reuse_win = true })
        end, { buffer = ev.buf, desc = "telescope.builtin lsp_definitions" })
        -- { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
        vim.keymap.set("n", "gr", function()
            require("telescope.builtin").lsp_references({ reuse_win = true })
        end, { buffer = ev.buf, desc = "telescope.builtin lsp_references" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", function()
            require("telescope.builtin").lsp_implementations({ reuse_win = true })
        end, { buffer = ev.buf, desc = "telescope.builtin lsp_implementations" })
        vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "lsp signature_help" })

        -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
        -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
        -- vim.keymap.set("n", "<space>wl", function()
        --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        -- end, opts)
        vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, { buffer = ev.buf, desc = "lsp type_definition" })
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, { buffer = ev.buf, desc = "lsp rename" })
        vim.keymap.set(
            { "n", "v" },
            "<space>ca",
            vim.lsp.buf.code_action,
            { buffer = ev.buf, desc = "lsp code_action" }
        )
        -- vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        -- vim.keymap.set("n", "<space>f", function()
        --   vim.lsp.buf.format { async = true }
        -- end, opts)
    end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem = {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
        properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
        },
    },
}
-- Setup language servers.
local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
        },
    },
})

-- setup multiple servers with same default options
local servers = { "tsserver", "html", "cssls" }

for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup({
        capabilities = capabilities,
    })
end
