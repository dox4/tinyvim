require("nvim-tree").setup({
    sort = {
        sorter = "case_sensitive",
    },
    update_focused_file = {
        enable = true,
        update_root = {
            enable = false,
            ignore_list = {},
        },
        exclude = false,
        update_cwd = false,
    },
    actions = {
        change_dir = {
            enable = false,
        },
    },
})
