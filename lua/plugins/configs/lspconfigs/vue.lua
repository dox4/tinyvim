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
    settings = {
        vtsls = {
            tsserver = {
                globalPlugins = {
                    vue_plugin,
                },
            },
        },
        typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
                completeFunctionCalls = true,
            },
            preferences = {
                importModuleSpecifier = "non-relative",
                quoteStyle = "double",
            },
            format = {
                semicolons = "remove",
            },
        },
    },
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
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

return { vue_ls_config, vtsls_config }
