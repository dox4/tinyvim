local M = {}
function M.enable_inner_options()
    return os.getenv("ENABLE_NVIM_INNER_OPTIONS") ~= nil
end

-- for security reasons, use environment variable to set the inner plugin url
-- exposing inner url to github is not allowed
function M.get_inner_plugin_url()
    local url = os.getenv("NVIM_INNER_PLUGIN_URL")
    if url == nil or url == "" then
        vim.notify("nvim_inner_plugin_url is not set", vim.log.levels.ERROR, { title = "nvim_inner_plugin_url" })
		error("NVIM_INNER_PLUGIN_URL not set.")
    end
    return url
end

function M.setup()
    if not M.enable_inner_options() then
        vim.notify("inner options is not enabled", vim.log.levels.WARN, { title = "inner options" })
        return
    end
    -- using trae(internal)
    -- 关闭 trae 内置自动补全
    vim.g.trae_disable_autocompletion = true
    -- 关闭 trae 内置 tab 映射
    vim.g.trae_no_map_tab = true
    -- 关闭 trae 内置补全映射
    vim.g.trae_disable_bindings = true

    local augroup = vim.api.nvim_create_augroup("inner_commands", { clear = true })
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = augroup,
        pattern = "*.ps",
        callback = function()
            vim.cmd("set filetype=json")
        end,
    })
end

return M
