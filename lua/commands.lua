local augroup = vim.api.nvim_create_augroup("user_commands", { clear = true })
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = augroup,
    pattern = "term://*",
    callback = function(ev)
        local opts = { buffer = ev.buf }
        -- vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
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

local function index_of(t, elem)
    for idx, v in ipairs(t) do
        if v == elem then
            return idx
        end
    end
    return nil
end
vim.api.nvim_create_autocmd("BufLeave", {
    group = augroup,
    pattern = "*",
    callback = function(ev)
        if vim.g.buffers_cache == nil then
            vim.g.buffers_cache = {}
        end
        if vim.g.max_buffers_cache_length == nil then
            vim.g.max_buffers_cache_length = 10
        end
        local buf = ev.buf
        -- local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        -- if ft == "NvimTree" then
        --     vim.notify("skip NvimTree buffer, index is " .. (buf), vim.log.levels.DEBUG)
        --     return
        -- end
        local idx = index_of(vim.g.buffers_cache, buf)
        if idx ~= nil then
            table.remove(vim.g.buffers_cache, idx)
        end
        table.insert(vim.g.buffers_cache, buf)
        if #vim.g.buffers_cache > vim.g.max_buffers_cache_length then
            table.remove(vim.g.buffers_cache, 1)
        end
    end,
})
