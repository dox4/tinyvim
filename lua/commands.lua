local augroup = vim.api.nvim_create_augroup("user_commands", { clear = true })
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

-- vim.api.nvim_create_autocmd("VimEnter", {
--     group = augroup,
--     callback = function()
--         require("nvim-tree.api").tree.toggle({ focus = false, find_file = true })
--     end,
-- })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    pattern = "*",
    callback = function(_)
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 500 })
    end,
})

vim.api.nvim_create_autocmd("BufLeave", {
    group = augroup,
    pattern = "*",
    callback = function(ev)
        vim.g.last_buffer_number = ev.buf
    end,
})
