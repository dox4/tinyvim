require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        go = { "goimports", "gofmt", "gofumpt" },
        python = function(bufnr)
            if require("conform").get_formatter_info("ruff_format", bufnr).available then
                return { "ruff_format" }
            else
                return { "isort", "autopep8" }
            end
        end,
        sh = { "shfmt" },
    },
    format_on_save = {
        -- I recommend these options. See :help conform.format for details.
        lsp_fallback = true,
        timeout_ms = 500,
    },
    formatters = {
        autopep8 = {
            inherit = true,
            prepend_args = { "--max-line-length", "120" },
        },
    },
})
