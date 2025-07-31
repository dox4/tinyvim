vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"

local opt = vim.opt

vim.g.autoformat = false
vim.g.mapleader = " "

opt.laststatus = 3 -- global statusline
-- opt.showmode = false
opt.autowrite = true

opt.colorcolumn = "120" -- set ruler
opt.mouse = "" -- disable mouse
opt.relativenumber = false -- disable relativenumber
opt.tabstop = 4 -- number of spaces tabs count for
opt.shiftwidth = 4
opt.autoindent = true
opt.expandtab = false
opt.smartindent = true
opt.number = true

opt.conceallevel = 0

opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.termguicolors = true -- True color support
opt.background = "dark"
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.wrap = false -- Disable line wrap

local o = vim.o

o.showmode = false
o.splitkeep = "screen"

o.clipboard = "unnamedplus"

opt.fillchars = { eob = " " }
o.ignorecase = true
o.smartcase = true

opt.shortmess:append("sI")

o.splitbelow = true
o.splitright = true

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append("<>[]hl")

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- add binaries installed by mason.nvim to path
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.env.PATH .. (is_windows and ";" or ":") .. vim.fn.stdpath("data") .. "/mason/bin"

-- vim.diagnostic
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
        },
    },
    virtual_text = true,
    underline = true,
})
