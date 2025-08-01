local M = {}
function M.enable_inner_options()
    return os.getenv("ENABLE_NVIM_INNER_OPTIONS") ~= nil
end

function M.setup()
    if not M.enable_inner_options() then
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
