return {
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
    }
