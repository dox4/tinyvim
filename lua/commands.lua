-- auto save current buffer
local augroup = vim.api.nvim_create_augroup("user_commands", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    group = augroup,
    pattern = "*",
    callback = function()
        local bufnum = vim.api.nvim_get_current_buf()

        -- buf not loaded
        if vim.fn.bufloaded(bufnum) ~= 1 then
            return
        end

        local is_modifiable = function()
            return vim.fn.getbufvar(bufnum, "&modifiable") == 1
        end
        if is_modifiable() then
            local bufname = vim.api.nvim_buf_get_name(bufnum)
            -- maybe a plugin-defined but not an exactly condition
            if bufname == "" then
                return
            end
            vim.api.nvim_buf_call(bufnum, function()
                -- format on auto save
                -- require("conform").format()
                vim.cmd("silent! write")
            end)
            local msg = ("buf %%%d: %s automatically saved at %s."):format(bufnum, bufname, vim.fn.strftime("%H:%M:%S"))
            vim.notify(msg, vim.log.levels.INFO)
        end
    end,
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = augroup,
    pattern = "term://*",
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], opts)
        -- vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
        -- vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    end,
})
