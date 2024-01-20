require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "rust_analyzer", "ruff_lsp", "gopls" },
})
