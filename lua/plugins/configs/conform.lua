require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofmt", "golines" },
        sh = { "shfmt" },
        json = { "prettier" },
        jsonc = { "prettier" },
        vue = { "prettier" },
        ts = { "prettier" },
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
