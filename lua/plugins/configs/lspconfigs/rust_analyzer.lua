return {
    on_attach = function(client, bufnr)
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end,
    settings = {
        ["rust-analyzer"] = {
            numThreads = 4,
            cachePriming = { numThreads = 2 },
            cargo = {
                loadOutDirsFromCheck = true,
                buildScripts = {
                    enable = true,
                },
            },
            files = {
                excludeDirs = { "target", ".git" },
            },
            imports = {
                granularity = {
                    group = "module",
                },
                prefix = "self",
            },
            checkOnSave = false,
            cacheOnDisk = true,
            lruCapacity = 65535,
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
