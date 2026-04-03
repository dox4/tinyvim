local augroup = vim.api.nvim_create_augroup("user_commands", { clear = true })
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = augroup,
    pattern = "term://*",
    callback = function(ev)
        local opts = { buffer = ev.buf, noremap = true, silent = true }
        -- vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
        vim.keymap.set("n", "q", "<CMD>close<CR>", opts)
        -- vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    pattern = "*",
    callback = function(_)
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 500 })
    end,
})

-- user event that loads after UIEnter + only if file buf is there
vim.api.nvim_create_autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("NvFilePost", { clear = true }),
    callback = function(args)
        local file = vim.api.nvim_buf_get_name(args.buf)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })

        if not vim.g.ui_entered and args.event == "UIEnter" then
            vim.g.ui_entered = true
        end

        if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
            vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
            vim.api.nvim_del_augroup_by_name("NvFilePost")

            vim.schedule(function()
                vim.api.nvim_exec_autocmds("FileType", {})

                if vim.g.editorconfig then
                    require("editorconfig").config(args.buf)
                end
            end)
        end
    end,
})

local function run_command_and_exit(cmd, title)
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.9),
        height = math.floor(vim.o.lines * 0.8),
        row = math.floor(vim.o.lines * 0.1),
        col = math.floor(vim.o.columns * 0.05),
        --  - "bold": Bold line box.
        -- 	- "double": Double-line box.
        -- 	- "none": No border.
        -- 	- "rounded": Like "single", but with rounded corners ("╭" etc.).
        -- 	- "shadow": Drop shadow effect, by blending with the background.
        -- 	- "single": Single-line box.
        -- 	- "solid": Adds padding by a single whitespace cell.
        border = "bold",
        title = title or cmd,
        title_pos = "left",
    })

    vim.fn.termopen(cmd)

    vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        once = true,
        callback = function()
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
        end,
    })

    vim.cmd("startinsert!")
end

-- 创建通用浮动窗口
local function create_floating_window(opts)
    opts = opts or {}
    local lines = opts.lines or { "No content" }
    local title = opts.title or "Floating Window"
    local filetype = opts.filetype or "text"
    local width_ratio = opts.width_ratio or 0.8
    local height_ratio = opts.height_ratio or 0.8
    local border = opts.border or "rounded"
    local title_pos = opts.title_pos or "center"
    local win_options = opts.win_options or {}

    -- 创建缓冲区
    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * width_ratio)
    local height = math.floor(vim.o.lines * height_ratio)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        border = border,
        title = title,
        title_pos = title_pos,
    })

    -- 设置缓冲区内容
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "filetype", filetype)

    -- 应用窗口选项
    for option, value in pairs(win_options) do
        vim.api.nvim_win_set_option(win, option, value)
    end

    -- 关闭窗口的键映射
    vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, { force = true })
    end, { buffer = buf })
    vim.keymap.set("n", "<Esc>", function()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, { force = true })
    end, { buffer = buf })

    return buf, win
end

vim.keymap.set("n", "<leader>gg", function()
    run_command_and_exit("lazygit")
end, { desc = "lazygit in float term" })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.toml.tpl", "*.toml.j2" },
    callback = function()
        vim.bo.filetype = "toml"
    end,
})

-- LspInfo command
local function show_lsp_info()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    if #clients == 0 then
        vim.notify("No LSP clients attached to current buffer", vim.log.levels.INFO)
        return
    end

    local lines = {}
    table.insert(lines, "LSP Clients for buffer " .. bufnr)
    table.insert(lines, string.rep("=", 40))

    for i, client in ipairs(clients) do
        table.insert(lines, string.format("%d. %s", i, client.name))
        table.insert(lines, string.format("   ID: %s", client.id))
        table.insert(lines, string.format("   Root directory: %s", client.config.root_dir or "N/A"))
        table.insert(lines, string.format("   Filetypes: %s", table.concat(client.config.filetypes or {}, ", ")))
        table.insert(lines, "   Capabilities:")
        local capabilities_str = vim.inspect(client.server_capabilities)
        for _, line in ipairs(vim.split(capabilities_str, "\n")) do
            table.insert(lines, "     " .. line)
        end
        table.insert(lines, "")
    end

    -- Create a floating window using the shared function
    create_floating_window({
        lines = lines,
        title = "LSP Info",
        filetype = "markdown",
        width_ratio = 0.8,
        height_ratio = 0.8,
        border = "rounded",
        title_pos = "center",
    })
end

vim.api.nvim_create_user_command("LspInfo", show_lsp_info, { desc = "Show LSP client information" })

-- LspLog command
local function show_lsp_log()
    local log_path = vim.lsp.log.get_filename()
    if not log_path or vim.fn.filereadable(log_path) == 0 then
        vim.notify("LSP log file not found: " .. (log_path or "N/A"), vim.log.levels.WARN)
        return
    end

    -- Read log file
    local lines = {}
    local file = io.open(log_path, "r")
    if file then
        for line in file:lines() do
            table.insert(lines, line)
        end
        file:close()
    else
        vim.notify("Failed to open log file: " .. log_path, vim.log.levels.ERROR)
        return
    end

    if #lines == 0 then
        lines = { "Log file is empty" }
    end

    -- Create a floating window using the shared function
    create_floating_window({
        lines = lines,
        title = "LSP Log: " .. log_path,
        filetype = "log",
        width_ratio = 0.9,
        height_ratio = 0.8,
        border = "rounded",
        title_pos = "center",
        win_options = {
            wrap = true,
            linebreak = true,
        },
    })
end

vim.api.nvim_create_user_command("LspLog", show_lsp_log, { desc = "Show LSP log file" })
