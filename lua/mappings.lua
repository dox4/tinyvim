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
map("n", "<leader>fd", "<cmd> Telescope diagnostics <CR>", { desc = "Telescope diagnostics" })
map("n", "<leader>ft", function()
    require("nvchad.themes").open()
end, { desc = "telescope nvchad themes" })

map("n", "<Tab>", function()
    require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

map("n", "<S-Tab>", function()
    require("nvchad.tabufline").prev()
end, { desc = "buffer goto prev" })

-- outline
map("n", "<leader>a", "<cmd>AerialToggle!<CR>")

-- format
map("n", "<leader>lf", function()
    require("conform").format({
        lsp_fallback = true,
        async = true,
        timeout_ms = 1500,
    })
end, { desc = "conform format" })
map("v", "<leader>f", function()
    require("conform").format({
        lsp_fallback = true,
        range = {
            -- 获取选中区域的起始和结束行号
            start = vim.api.nvim_buf_get_mark(0, "<"),
            ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
        },
    })
end, { desc = "ranged format" })

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
map("n", "<leader>bd", function()
    require("nvchad.tabufline").close_buffer()
end, { desc = "delete current buffer" })

-- quit all
map("n", "<leader>qq", "<cmd> confirm quitall <CR>", { desc = "confirm quit all" })

-- noh 清除匹配高亮
map("n", "<Esc>", "<cmd> noh <cr>", { desc = "clear search match highlight" })

-- overseer
-- OverseerBuild
-- OverseerClearCache
-- OverseerClose
-- OverseerDeleteBundle
-- OverseerInfo
map("n", "<leader>oi", "<cmd> OverseerInfo <CR>", { desc = "OverseerInfo" })
-- OverseerLoadBundle
-- OverseerOpen
map("n", "<leader>oo", "<cmd> OverseerOpen <CR>", { desc = "OverseerOpen" })
-- OverseerQuickAction
-- OverseerRun
map("n", "<leader>or", "<cmd> OverseerRun <CR>", { desc = "OverseerRun" })
-- OverseerRunCmd
-- OverseerSaveBundle
-- OverseerTaskAction
-- OverseerToggle
map("n", "<leader>ot", "<cmd> OverseerToggle <CR>", { desc = "OverseerToggle" })

map({ "n", "t" }, "<leader>th", function()
    require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm" })
end, { desc = "terminal toggleable horizontal term" })

map({ "n", "t" }, "<leader>tf", function()
    require("nvchad.term").toggle({
        pos = "float",
        id = "floatTerm",
        float_opts = {
            width = 0.9,
            height = 0.8,
            row = 0.08,
            col = 0.05,
            title = "Run Something",
            title_pos = "right",
        },
    })
end, { desc = "terminal toggle floating term" })

map("n", "<leader>sf", "<cmd> echo expand('%') <CR>", { desc = "show current file path" })
map("n", "<leader>cf", "<cmd>%y+<CR>", { desc = "general copy whole file" })
map("n", "<leader>cp", "<cmd>let @+ = expand('%')<CR>", { desc = "copy relative path of current file." })

map("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "go to previous diagnostic" })
map("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true, virtual_text = true })
end, { desc = "go to next diagnostic" })
-- vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)
