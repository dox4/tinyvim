local function find_go_mod_dir(opts)
    local found = vim.fs.find("go.mod", { path = opts.dir, upward = true, type = "file" })
    if #found > 0 then
        return vim.fs.dirname(found[1])
    end
    return nil
end

return {
    cache_key = function(opts)
        return find_go_mod_dir(opts)
    end,

    generator = function(opts, cb)
        if vim.fn.executable("go") == 0 then
            return 'Command "go" not found'
        end

        local cwd = find_go_mod_dir(opts)
        if not cwd then
            return "No go.mod found"
        end

        local tasks = {
            {
                name = "go run .",
                desc = "Run Go program",
                builder = function()
                    return { cmd = { "go", "run", "." }, cwd = cwd }
                end,
            },
            {
                name = "go build",
                desc = "Build Go program",
                builder = function()
                    return { cmd = { "go", "build" }, cwd = cwd }
                end,
            },
            {
                name = "go test ./...",
                desc = "Run all tests",
                builder = function()
                    return { cmd = { "go", "test", "./..." }, cwd = cwd }
                end,
            },
            {
                name = "go test -v ./...",
                desc = "Run all tests with verbose",
                builder = function()
                    return { cmd = { "go", "test", "-v", "./..." }, cwd = cwd }
                end,
            },
            {
                name = "go test",
                desc = "Run tests in current package",
                params = {
                    path = { type = "string", desc = "Test path", optional = true, default = "." },
                    run = { type = "string", desc = "Test name pattern", optional = true },
                },
                builder = function(params)
                    local cmd = { "go", "test" }
                    if params.run and params.run ~= "" then
                        vim.list_extend(cmd, { "-run", params.run })
                    end
                    table.insert(cmd, params.path)
                    return { cmd = cmd, cwd = cwd }
                end,
            },
            {
                name = "go mod tidy",
                desc = "Tidy go.mod",
                builder = function()
                    return { cmd = { "go", "mod", "tidy" }, cwd = cwd }
                end,
            },
            {
                name = "go mod download",
                desc = "Download dependencies",
                builder = function()
                    return { cmd = { "go", "mod", "download" }, cwd = cwd }
                end,
            },
            {
                name = "go fmt ./...",
                desc = "Format code",
                builder = function()
                    return { cmd = { "go", "fmt", "./..." }, cwd = cwd }
                end,
            },
            {
                name = "go vet ./...",
                desc = "Run go vet",
                builder = function()
                    return { cmd = { "go", "vet", "./..." }, cwd = cwd }
                end,
            },
            {
                name = "go run . (with auto-restart)",
                desc = "Run with auto-restart on file changes",
                builder = function()
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
                    }
                end,
            },
        }
        cb(tasks)
    end,
}
