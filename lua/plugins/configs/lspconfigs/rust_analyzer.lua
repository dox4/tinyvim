return {
    on_attach = function(client, bufnr)
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end,
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                loadOutDirsFromCheck = true,
                buildScripts = {
                    enable = true,
                },
            },
            imports = {
                granularity = {
                    group = "module",
                },
                prefix = "self",
            },
            checkOnSave = true,
            procMacro = {
                enable = true,
                ignored = {
                    ["async-trait"] = { "async_trait" },
                    ["napi-derive"] = { "napi" },
                    ["async-recursion"] = { "async_recursion" },
                },
            },
        },
    },
}
