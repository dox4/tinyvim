require("options")
require("mappings")
require("commands")

-- bootstrap plugins & lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- path where its going to be installed

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require("plugins")

-- set random color scheme
local function randcs()
    local themes = {
        "dracula",
        "tokyonight",
        "monokai-pro",
        "onedark",
    }
    math.randomseed(os.time())
    local index = math.random(#themes)
    local theme = themes[index]
    vim.notify("set random theme: " .. theme, vim.log.levels.INFO)
    return theme
end

vim.cmd("colorscheme " .. randcs())
