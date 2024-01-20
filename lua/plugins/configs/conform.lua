require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        javascript = { { "prettier" } },
    },
    format_on_save = {
        -- I recommend these options. See :help conform.format for details.
        lsp_fallback = true,
        timeout_ms = 500,
    },
})
