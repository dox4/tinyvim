dofile(vim.g.base46_cache .. "git")
require("gitsigns").setup({
    auto_attach = true,
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
    },
    -- current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000, -- Disable if file is longer than this (in lines)
    preview_config = {
        -- Options passed to nvim_open_win
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
    },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, keys, operation, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, keys, operation, opts)
        end
        -- Navigation
        map("n", "]c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
            else
                gs.nav_hunk("next")
            end
        end)

        map("n", "[c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
            else
                gs.nav_hunk("prev")
            end
        end)
        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, { desc = "stage hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "reset hunk" })
        map("v", "<leader>hs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end)
        map("v", "<leader>hr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end)
        map("n", "<leader>hS", gs.stage_buffer, { desc = "stage buffer" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "reset buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "preview hunk" })
        map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
        end, { desc = "blame line" })
        map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "toggle current line blame" })
        map("n", "<leader>hd", gs.diffthis, { desc = "diff this" })
        map("n", "<leader>hD", function()
            gs.diffthis("~")
        end, { desc = "diff this (~)" })
        -- map("n", "<leader>td", gs.toggle_deleted)

        -- Text object
        -- map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
    end,
})
