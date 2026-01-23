local dap = require("dap")

-- Go

-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
dap.adapters.delve = {
    type = "server",
    port = "${port}",
    executable = {
        command = "dlv",
        args = { "dap", "-l", "127.0.0.1:${port}" },
        -- add this if on windows, otherwise server won't open successfully
        detached = vim.loop.os_uname().sysname ~= "Windows_NT",
    },
}
dap.adapters.go = dap.adapters.delve

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
    {
        type = "delve",
        name = "Debug",
        request = "launch",
        program = "${workspaceFolder}",
    },
    {
        type = "delve",
        name = "Debug test", -- configuration for debugging test files
        request = "launch",
        mode = "test",
        program = "${file}",
    },
    -- works with go.mod packages and sub packages
    {
        type = "delve",
        name = "Debug test (go.mod)",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}",
    },
}

-- Python

local function get_system_python()
    -- 尝试不同的 Python 命令
    local commands = {  "python" }

    for _, cmd in ipairs(commands) do
        local path = vim.fn.exepath(cmd)
        if path ~= "" then
            return path
        end
    end

    return vim.fn.has("win32") == 1 and "python.exe" or "python3"
end

local function find_python_path()
    local cwd = vim.fn.getcwd()
    local venv_path = cwd .. "/.venv"

    if vim.fn.isdirectory(venv_path) == 1 then
        local python_executable
        if vim.fn.has("win32") == 1 then
            python_executable = venv_path .. "\\Scripts\\python.exe"
        else
            python_executable = venv_path .. "/bin/python"
        end

        if vim.fn.filereadable(python_executable) == 1 then
            return python_executable
        end
    end

    return get_system_python()
end

dap.adapters.python = function(cb, config)
    if config.request == "attach" then
        ---@diagnostic disable-next-line: undefined-field
        local port = (config.connect or config).port
        ---@diagnostic disable-next-line: undefined-field
        local host = (config.connect or config).host or "127.0.0.1"
        cb({
            type = "server",
            port = assert(port, "`connect.port` is required for a python `attach` configuration"),
            host = host,
            options = {
                source_filetype = "python",
            },
        })
    else
        cb({
            type = "executable",
            command = find_python_path(),
            args = { "-m", "debugpy.adapter" },
            options = {
                source_filetype = "python",
            },
        })
    end
end

dap.adapters.debugpy = dap.adapters.python

dap.configurations.python = {
    {
        -- The first three options are required by nvim-dap
        type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = "launch",
        name = "Launch file",
        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
        program = "${file}", -- This configuration will launch the current file if used.
        pythonPath = python_exec,
    },
}
