require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofmt", "golines" },
        sh = { "shfmt" },
        json = { "prettier" },
        jsonc = { "prettier" },
        vue = { "prettier" },
        typescript = { "prettier" },
        javascript = { "prettier" },
    },
    formatters = {
        prettier = {
            inherit = true,
            prepend_args = function(_, ctx)
                local cmd = "prettier --find-config-path " .. ctx.filename
                local prettierrc = vim.fn.system(cmd)
                if vim.v.shell_error == 0 then
                    local function trim(s)
                        return s:match("^%s*(.-)%s*$")
                    end
                    prettierrc = trim(prettierrc)
                    return { "--config", prettierrc }
                end
                return { "--tab-width", "4" }
            end,
        },

        golines = {
            inherit = true,
            prepend_args = { "-m", "120" },
        },
    },
})
