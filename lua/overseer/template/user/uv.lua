local function get_pyproject(opts)
    return vim.fs.find("pyproject.toml", { upward = true, type = "file", path = opts.dir })[1]
end

local function get_uv_lock(opts)
    return vim.fs.find("uv.lock", { upward = true, type = "file", path = opts.dir })[1]
end

local function get_scripts_from_pyproject(pyproject)
    local scripts = {}

    local taohua = require("taohua")
    local ret = taohua.parse_toml(pyproject)
    if not ret.ok then
        vim.notify("Failed to parse pyproject.toml: " .. (ret.error or "unknown error"), vim.log.levels.WARN)
        return scripts
    end

    local parsed = ret.value
    if parsed.project and parsed.project.scripts then
        for name, command in pairs(parsed.project.scripts) do
            if type(command) == "string" then
                table.insert(scripts, { name = name, command = command })
            end
        end
    end
    return scripts
end

return {
    cache_key = function(opts)
        return get_uv_lock(opts) or get_pyproject(opts)
    end,

    generator = function(opts, cb)
        if vim.fn.executable("uv") == 0 then
            return 'Command "uv" not found'
        end

        local pyproject = get_pyproject(opts)
        local uv_lock = get_uv_lock(opts)
        if not pyproject and not uv_lock then
            return "No pyproject.toml or uv.lock found"
        end

        local cwd = vim.fs.dirname(pyproject or uv_lock)
        local ret = {}

        for _, item in ipairs({
            { name = "uv sync", cmd = { "uv", "sync" }, desc = "Sync dependencies from lock file" },
            { name = "uv lock", cmd = { "uv", "lock" }, desc = "Generate/update lock file" },
            { name = "uv build", cmd = { "uv", "build" }, desc = "Build the project" },
            { name = "uv publish", cmd = { "uv", "publish" }, desc = "Publish to PyPI" },
            { name = "uv venv", cmd = { "uv", "venv" }, desc = "Create venv" },
            { name = "uv pip list", cmd = { "uv", "pip", "list" }, desc = "List packages" },
        }) do
            table.insert(ret, {
                name = item.name,
                desc = item.desc,
                builder = function()
                    return { cmd = item.cmd, cwd = cwd }
                end,
            })
        end

        table.insert(ret, {
            name = "uv run python",
            desc = "Run Python script",
            params = {
                script = { type = "string", desc = "Script path", optional = false },
                args = { type = "string", desc = "Arguments", optional = true },
            },
            builder = function(params)
                local cmd = { "uv", "run", "python", params.script }
                if params.args and params.args ~= "" then
                    vim.list_extend(cmd, vim.split(params.args, " "))
                end
                return { cmd = cmd, cwd = cwd }
            end,
        })

        local scripts = get_scripts_from_pyproject(pyproject)

        for _, script in ipairs(scripts) do
            table.insert(ret, {
                name = string.format("uv run %s", script.name),
                desc = string.format("Script: %s", script.command),
                builder = function()
                    return { cmd = { "uv", "run", script.name }, cwd = cwd }
                end,
            })
        end

        table.insert(ret, {
            name = "uv run pytest",
            desc = "Run tests",
            params = {
                path = { type = "string", desc = "Test path", optional = true, default = "" },
                args = { type = "string", desc = "Extra args", optional = true },
            },
            builder = function(params)
                local cmd = { "uv", "run", "pytest" }
                if params.path and params.path ~= "" then
                    table.insert(cmd, params.path)
                end
                if params.args and params.args ~= "" then
                    vim.list_extend(cmd, vim.split(params.args, " "))
                end
                return { cmd = cmd, cwd = cwd }
            end,
        })

        table.insert(ret, {
            name = "uv add",
            desc = "Add dependency",
            params = {
                package = { type = "string", desc = "Package", optional = false },
                dev = { type = "boolean", desc = "Dev dependency", optional = true, default = false },
            },
            builder = function(params)
                local cmd = { "uv", "add" }
                if params.dev then
                    table.insert(cmd, "--dev")
                end
                table.insert(cmd, params.package)
                return { cmd = cmd, cwd = cwd }
            end,
        })

        table.insert(ret, {
            name = "uv remove",
            desc = "Remove dependency",
            params = { package = { type = "string", desc = "Package", optional = false } },
            builder = function(params)
                return { cmd = { "uv", "remove", params.package }, cwd = cwd }
            end,
        })

        cb(ret)
    end,
}
