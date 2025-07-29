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

vim.keymap.set("n", "<leader>gg", function()
    run_command_and_exit("lazygit")
end, { desc = "lazygit in float term" })
