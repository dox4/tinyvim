local opts = {
    keymap = {
        preset = "enter",

        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },
    sources = {
        -- `lsp`, `buffer`, `snippets`, `path` and `omni` are built-in
        -- so you don't need to define them in `sources.providers`
        default = { "lsp", "buffer", "snippets", "path", "datword", "trae" },

        providers = {
            -- add datword provider
            datword = {
                name = "Word",
                module = "blink-cmp-dat-word",
                score_offset = -50,
                opts = {
                    paths = {
                        "/usr/share/dict/words", -- This file is included by default on Linux/macOS.
                    },
                    build_command = "BuildDatWord", -- Define a Command to rebuild words, eg: `BuildDatWord`, then use `BuildDatWord!` to force rebuild cache.
                    spellsuggest = true, -- Enable limited spellsuggest. eg: enter `thsi` give you `this`.
                },
            },

            trae = {
                name = "trae",
                module = "blink.compat.source",
                score_offset = 500,
                opts = {},
            },
        },
    },
    completion = {
        documentation = { auto_show = true, window = { border = "single" } },
        menu = {
            -- auto_show_delay_ms = 500,
            draw = {
                -- We don't need label_description now because label and label_description are already
                -- combined together in label by colorful-menu.nvim.
                columns = { { "kind_icon" }, { "label", gap = 1 }, { "source_name" } },
                components = {
                    label = {
                        text = function(ctx)
                            return require("colorful-menu").blink_components_text(ctx)
                        end,
                        highlight = function(ctx)
                            return require("colorful-menu").blink_components_highlight(ctx)
                        end,
                    },
                },
            },
            -- border = "single",
        },
        accept = {
            auto_brackets = {
                enabled = true,
            },
        },
        -- preselect and auto_insert are enabled by default
        list = { cycle = { from_top = true } },
        ghost_text = { enabled = true },
    },
    cmdline = {
        completion = {
            list = {
                selection = {
                    auto_insert = true,
                },
            },
        },
    },
}

return opts
