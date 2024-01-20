local opt = vim.opt

vim.g.autoformat = false
vim.g.mapleader = " "

opt.laststatus = 3 -- global statusline
-- opt.showmode = false

opt.clipboard = "unnamedplus"

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
opt.list = true
opt.listchars:append({ trail = "·" })
opt.listchars:append({ nbsp = "◇" })
opt.listchars:append({ tab = "│ " })
opt.listchars:append({ leadmultispace = "┆   " })
opt.listchars:append({ extends = "▸" })
opt.listchars:append({ precedes = "◂" })

opt.conceallevel = 0

-- add binaries installed by mason.nvim to path
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.env.PATH .. (is_windows and ";" or ":") .. vim.fn.stdpath("data") .. "/mason/bin"
