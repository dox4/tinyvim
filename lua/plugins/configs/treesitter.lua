require("nvim-treesitter.configs").setup({
    ensure_installed = { "lua", "go", "python", "rust" },

    highlight = {
        enable = true,
        use_languagetree = true,
    },
    indent = { enable = true },
})
