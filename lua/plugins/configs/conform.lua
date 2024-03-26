require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofmt", "golines" },
        sh = { "shfmt" },
        json = { "prettier" },
    },
    format_on_save = {
        -- I recommend these options. See :help conform.format for details.
        lsp_fallback = true,
        timeout_ms = 500,
    },
    formatters = {
        prettier = {
            inherit = true,
            prepend_args = { "--tab-width", "4" },
        },

        golines = {
            inherit = true,
            prepend_args = { "-m", "120" },
        },
    },
})
