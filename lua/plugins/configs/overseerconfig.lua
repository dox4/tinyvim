-- 模块化：暴露注册 opts 与注册模板的两个方法
local M = {}

-- 在多仓库/单仓库中自动定位最近的 go.mod 目录
local function find_go_mod_dir()
    local current_dir = vim.fn.getcwd()
    local ignore_dirs = { ".git", "node_modules", "vendor", "dist", "build" }

    local function search_subdirs(dir)
        if vim.fn.filereadable(dir .. "/go.mod") == 1 then
            return dir
        end

        local entries = vim.fn.readdir(dir, function(name)
            local full_path = dir .. "/" .. name
            return not vim.tbl_contains(ignore_dirs, name) and vim.fn.isdirectory(full_path) == 1
        end)

        for _, entry in ipairs(entries) do
            local sub_dir = dir .. "/" .. entry
            local found = search_subdirs(sub_dir)
            if found then
                return found
            end
        end
        return nil
    end

    local found_dir = search_subdirs(current_dir)
    return found_dir or current_dir
end

function M.register_opts(opts)
    local overseer = require("overseer")
    overseer.setup(opts or { dap = false })
end

function M.register_templates()
    local overseer = require("overseer")
    local templates = {
        {
            name = "Go Auto Restart",
            desc = "Run Go program and auto-restart on .go file changes (monorepo friendly)",
            tags = { "go", "dev", "auto-restart" },
            params = {
                cwd = {
                    type = "string",
                    default = find_go_mod_dir(),
                    desc = "Working dir for Go project (auto-filled with nearest go.mod dir)",
                },
            },
            builder = function(params)
                local cwd = vim.fn.fnamemodify(params.cwd, ":p")

                if vim.fn.isdirectory(cwd) == 0 then
                    vim.notify("⚠️ Go work dir not exist: " .. cwd, vim.log.levels.WARN)
                elseif vim.fn.filereadable(cwd .. "/go.mod") == 0 then
                    vim.notify("⚠️ No go.mod found in: " .. cwd, vim.log.levels.WARN)
                end

                return {
                    cmd = { "go", "run", "." },
                    cwd = cwd,
                    components = {
                        "default",
                        {
                            "restart_on_save",
                            patterns = { "*.go", "go.mod", "go.sum" },
                            ignore_patterns = { "vendor/*", ".git/*" },
                            cwd = cwd,
                        },
                    },
                    metadata = {
                        output_stream = "terminal",
                    },
                }
            end,
            condition = nil,
        },
    }

    for _, tpl in ipairs(templates) do
        overseer.register_template(tpl)
    end
end

return M
