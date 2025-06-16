-- Global mappings.
-- vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
-- vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

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
        vim.lsp.inlay_hint.enable(true)
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

vim.lsp.config("lua_ls", {
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
        },
    },
})

vim.lsp.config("gopls", {
    capabilities = capabilities,
    settings = {
        gopls = {
            gofumpt = true,
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
            analyses = {
                inlines = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            semanticTokens = true,
            staticcheck = (function()
                local go_version = (function()
                    if vim.loop.os_uname().sysname == "Windows_NT" then
                        return vim.fn.system("go version")
                    else
                        local path = vim.fn.getenv("PATH")
                        return vim.fn.system("PATH=" .. path .. " go version")
                    end
                end)()
                local captured_version = string.match(go_version, "go(%d+.%d+.%d+)")
                return captured_version and captured_version > "1.18.10"
            end)(),
        },
    },
})

vim.lsp.config("rust_analyzer", {
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
            },
            -- Add clippy lints for Rust.
            checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
            },
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
})

vim.lsp.config("ruff", {
    capabilities = capabilities,
    on_attach = function(client, _)
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
    end,
    init_options = {
        settings = {
            format = {
                args = {
                    "--line-length",
                    "120",
                },
            },
            args = {},
        },
    },
})
vim.lsp.config("pyright", {
    capabilities = capabilities,
})
vim.lsp.config("clangd", {
    capabilities = capabilities,
})

vim.lsp.config("bashls", {
    capabilities = capabilities,
})

-- For Mason v2,
local vue_language_server_path = vim.fn.expand("$MASON/packages")
    .. "/vue-language-server"
    .. "/node_modules/@vue/language-server"
-- or even
-- local vue_language_server_path = vim.fn.stdpath('data') .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
local vue_plugin = {
    name = "@vue/typescript-plugin",
    location = vue_language_server_path,
    languages = { "vue" },
    configNamespace = "typescript",
}
local vtsls_config = {
    init_options = {
        plugins = {
            vue_plugin,
        },
    },
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
    settings = {
        complete_function_calls = true,
        vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
                maxInlayHintLength = 30,
                completion = {
                    enableServerSideFuzzyMatch = true,
                },
            },
        },
        typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
                completeFunctionCalls = true,
            },
            inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = true },
            },
            preferences = {
                quoteStyle = "double",
            },
        },
    },
}
local vue_ls_config = {
    filetypes = { "vue" },
    on_init = function(client)
        client.handlers["tsserver/request"] = function(_, result, context)
            local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
            if #clients == 0 then
                vim.notify(
                    "Could not found `vtsls` lsp client, vue_lsp would not work without it.",
                    vim.log.levels.ERROR
                )
                return
            end
            local ts_client = clients[1]

            local param = unpack(result)
            local id, command, payload = unpack(param)
            ts_client:exec_cmd({
                command = "typescript.tsserverRequest",
                arguments = {
                    command,
                    payload,
                },
            }, { bufnr = context.bufnr }, function(_, r)
                local response_data = { { id, r.body } }
                ---@diagnostic disable-next-line: param-type-mismatch
                client:notify("tsserver/response", response_data)
            end)
        end
    end,
    init_options = {
        vue = {
            hybridMode = false,
        },
    },
}
-- nvim 0.11 or above
vim.lsp.config("vtsls", vtsls_config)
vim.lsp.config("vue_ls", vue_ls_config)
vim.lsp.enable("vtsls")
vim.lsp.enable("vue_ls")
vim.lsp.config("eslint", {})

