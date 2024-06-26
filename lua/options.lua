local opt = vim.opt
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.autoformat = false
vim.g.mapleader = " "

opt.laststatus = 3 -- global statusline
-- opt.showmode = false
opt.autowrite = true
-- opt.clipboard = "unnamedplus"
vim.cmd("set clipboard=unnamedplus")

opt.colorcolumn = "120" -- set ruler
opt.mouse = "" -- disable mouse
opt.relativenumber = false -- disable relativenumber
opt.tabstop = 4 -- number of spaces tabs count for
opt.shiftwidth = 4
opt.autoindent = true
opt.expandtab = false
opt.smartindent = true
opt.number = true

-- set listchars=trail:·,nbsp:◇,tab:│\ ,leadmultispace:\┆\ \ \ ,extends:Îõ,precedes:Îõ
-- opt.list = true
-- opt.listchars:append({ trail = "·" })
-- opt.listchars:append({ nbsp = "◇" })
-- opt.listchars:append({ tab = "│ " })
-- opt.listchars:append({ leadmultispace = "┆   " })
-- opt.listchars:append({ extends = "▸" })
-- opt.listchars:append({ precedes = "◂" })

opt.conceallevel = 0

opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.termguicolors = true -- True color support
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.wrap = false -- Disable line wrap

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- add binaries installed by mason.nvim to path
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.env.PATH .. (is_windows and ";" or ":") .. vim.fn.stdpath("data") .. "/mason/bin"
