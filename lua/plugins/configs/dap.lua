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

-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python

local function python_exec()
    -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
    -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
    -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
    local cwd = vim.fn.getcwd()
    if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
        return cwd .. "/venv/bin/python"
    elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
        return cwd .. "/.venv/bin/python"
    else
        return "python"
    end
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
            command = python_exec(),
            args = { "-m", "debugpy.adapter" },
            options = {
                source_filetype = "python",
            },
        })
    end
end

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
