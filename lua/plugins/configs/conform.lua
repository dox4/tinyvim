require("conform").setup({
    log_level = vim.log.levels.DEBUG,

    formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofmt", "golines" },
        sh = { "shfmt", "shellcheck" },
        json = { "prettier" },
        jsonc = { "prettier" },
        vue = { "prettier" },
        typescript = { "prettier" },
        javascript = { "prettier" },
        ps = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        yaml = { "yamlfmt" },
        python = function(_)
            -- 定位 pyproject.toml
            local root = vim.fn.getcwd()
            local pyproject = root .. "/pyproject.toml"

            -- 默认格式化工具列表
            local default_formatters = { "ruff_format", "ruff_organize_imports" }

            local function file_exists(path)
                local file = io.open(path, "rb")
                if file then
                    file:close()
                end
                return file ~= nil
            end
            if not file_exists(pyproject) then
                return default_formatters
            end

            local content = table.concat(vim.fn.readfile(pyproject), "\n")

            -- 检测工具配置
            local formatters = {}
            if content:match("%[tool%.black%]") then
                table.insert(formatters, "black")
            end
            if content:match("%[tool%.isort%]") then
                table.insert(formatters, "isort")
            end
            if content:match("%[tool%.ruff%]") then
                table.insert(formatters, "ruff_format")
                table.insert(formatters, "ruff_organize_imports")
            end

            return #formatters > 0 and formatters or default_formatters
        end,
        toml = { "taplo" },
        sql = { "sql_formatter" },
        terraform = { "terraform_fmt" },
        ocaml = { "ocamlformat" },
    },
    formatters = {
        prettier = {
            inherit = true,
            prepend_args = function(_, ctx)
                local buf = ctx.buf
                local ft = vim.api.nvim_buf_get_option(buf, "filetype")
                local function extend(t1, t2)
                    for _, value in ipairs(t2) do
                        table.insert(t1, value)
                    end
                    return t1
                end
                local args = {}
                if ft == "json" then
                    args = { "--parser", "json" }
                end
                local cmd = "prettier --find-config-path " .. ctx.filename
                local prettierrc = vim.fn.system(cmd)
                if vim.v.shell_error == 0 then
                    local function trim(s)
                        return s:match("^%s*(.-)%s*$")
                    end
                    prettierrc = trim(prettierrc)
                    return extend(args, { "--config", prettierrc })
                end
                return extend(args, { "--tab-width", "4" })
            end,
        },

        golines = {
            inherit = true,
            prepend_args = { "-m", "120" },
        },

        ruff_format = {},

        shfmt = {
            inherit = true,
            prepend_args = {
                "-i",
                "4",
                "-ci",
            },
        },

        taplo = {},

        black = {},

        sql_formatter = {},

        terraform_fmt = {},
        ocamlformat = {},
    },
})
