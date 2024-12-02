local Terminal = require("toggleterm.terminal").Terminal

-- lazygit
local lazygit = nil
vim.keymap.set("n", "<leader>gg", function()
    if lazygit == nil then
        lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float", close_on_exit = true })
    end
    lazygit:toggle()
end, { noremap = true, silent = true })
local default_terminal = nil

-- default terminal
vim.keymap.set("n", "<F12>", function()
    if default_terminal == nil then
        default_terminal = Terminal:new({
            direction = "float",
            -- close_on_exit = true,
            on_open = function(term)
                vim.cmd("startinsert!")
                vim.keymap.set("n", "q", "<cmd>close<CR>", { noremap = true, silent = true, buffer = term.bufnr })
            end,
        })
    end
    default_terminal:toggle()
end)

local bottom_terminal = nil
vim.keymap.set("n", "<leader>bt", function()
    if bottom_terminal == nil then
        bottom_terminal = Terminal:new({
            direction = "horizontal",
            -- close_on_exit = true,
            on_open = function(term)
                vim.cmd("startinsert!")
                vim.keymap.set("n", "q", "<cmd>close<CR>", { noremap = true, silent = true, buffer = term.bufnr })
            end,
        })
    end
    bottom_terminal:toggle()
end, { desc = "toggle bottom terminal." })

require("toggleterm").setup({
    start_in_insert = true,
    persist_mode = false,
})
