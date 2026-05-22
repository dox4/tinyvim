local M = {}

function M.register_opts(opts)
    require("overseer").setup(opts or { dap = false })
end

function M.register_templates() end

return M
