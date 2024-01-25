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

-- telescope
map("n", "<leader>ff", "<cmd> Telescope find_files <CR>")
map("n", "<leader>fw", "<cmd> Telescope live_grep <CR>")
-- map("n", "<leader>fo", "<cmd> Telescope oldfiles <CR>")
-- map("n", "<leader>gt", "<cmd> Telescope git_status <CR>")

-- bufferline, cycle buffers
map("n", "<Tab>", "<cmd> BufferLineCycleNext <CR>")
map("n", "<S-Tab>", "<cmd> BufferLineCyclePrev <CR>")
map("n", "<C-q>", "<cmd> bd <CR>")

-- comment.nvim
map("n", "gcc", function()
    require("Comment.api").toggle.linewise.current()
end, { desc = "toggle current commented" })

map("v", "gc", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>")

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
map("n", "<leader>bd", "<cmd> bd <CR>", { desc = "delete current buffer" })

-- quit all
map("n", "<leader>qq", "<cmd> confirm quitall <CR>", { desc = "confirm quit all" })
