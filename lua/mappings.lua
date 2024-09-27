local map = vim.keymap.set

-- general mappings
map("n", "<C-s>", "<cmd> w <CR>")
map("i", "jk", "<ESC>")
map("n", "<C-c>", "<cmd> %y+ <CR>") -- copy whole filecontent

map("n", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("n", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("n", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("n", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- nvimtree
map("n", "<space>e", "<cmd> NvimTreeToggle <CR>")
-- map("n", "<C-h>", "<cmd> NvimTreeFocus <CR>")

local expand_nvim_tree = false
map("n", "<leader>nz", function()
    if expand_nvim_tree then
        vim.cmd("NvimTreeResize 30")
        expand_nvim_tree = false
    else
        vim.cmd("NvimTreeResize 100")
        expand_nvim_tree = true
    end
    vim.cmd("NvimTreeFocus")
end, { desc = "toggle nvim tree size" })
-- map("n", "<C-h>", "<cmd> NvimTreeFocus <CR>")

-- telescope
map("n", "<leader>ff", "<cmd> Telescope find_files <CR>", { desc = "Telescope find_files" })
map("n", "<leader>fw", "<cmd> Telescope live_grep <CR>", { desc = "Telescope live_grep" })
map("n", "<leader>fb", "<cmd> Telescope buffers <CR>", { desc = "Telescope buffers" })
-- map("n", "<leader>fo", "<cmd> Telescope oldfiles <CR>")
-- map("n", "<leader>gt", "<cmd> Telescope git_status <CR>")

-- bufferline, cycle buffers
map("n", "<Tab>", "<cmd> BufferLineCycleNext <CR>")
map("n", "<S-Tab>", "<cmd> BufferLineCyclePrev <CR>")

-- comment.nvim
map("n", "gcc", function()
    require("Comment.api").toggle.linewise.current()
end, { desc = "toggle current commented" })

map("v", "gc", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>")

-- outline
map("n", "<leader>a", "<cmd>AerialToggle!<CR>")

-- format
map("n", "<leader>lf", function()
    require("conform").format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
    })
end, { desc = "conform format" })

-- Lazy
map("n", "<leader>lz", "<cmd> Lazy <CR>", { desc = "Lazy" })

-- Mason
map("n", "<leader>lm", "<cmd> Mason <CR>", { desc = "Mason" })

-- LspInfo
map("n", "<leader>li", "<cmd> LspInfo <CR>", { desc = "LspInfo" })

-- Conform
map("n", "<leader>lc", "<cmd> ConformInfo <CR>", { desc = "ConformInfo" })

-- save file manually
map("n", "<C-s>", "<cmd> write <CR>", { desc = "save file manually" })

-- buffers
local function remove_of(ctx, buf)
    local index = 1
    local function file_type_ok(b)
        local file_type = vim.api.nvim_buf_get_option(b, "filetype")
        return file_type ~= nil and file_type ~= ""
    end
    while index <= #ctx.buffers_history do
        local buffer = ctx.buffers_history[index]
        if buffer == buf then
            table.remove(ctx.buffers_history, index)
        elseif not (vim.api.nvim_buf_is_valid(buffer) and vim.api.nvim_buf_is_loaded(buffer)) then
            table.remove(ctx.buffers_history, index)
        elseif not file_type_ok(buffer) then
            table.remove(ctx.buffers_history, index)
        else
            index = index + 1
        end
    end
end
map("n", "<leader>bd", function()
    local buf = vim.api.nvim_get_current_buf()
    local ctx = require("context")
    remove_of(ctx, buf)
    local last_buffer = ctx.buffers_history[#ctx.buffers_history]
    if last_buffer ~= nil then
        vim.api.nvim_set_current_buf(last_buffer)
    end
    vim.api.nvim_buf_delete(buf, {})
end, { desc = "delete current buffer" })

-- quit all
map("n", "<leader>qq", "<cmd> confirm quitall <CR>", { desc = "confirm quit all" })
