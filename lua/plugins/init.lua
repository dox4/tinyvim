local plugins = {
    { lazy = true, "nvim-lua/plenary.nvim" },

    -- themes
    { "dracula/vim" },
    {
        "folke/tokyonight.nvim",
        lazy = true,
        opts = {
            style = (function()
                if math.random() > 0.5 then
                    return "moon"
                else
                    return "night"
                end
            end)(),
            styles = {
                comments = { italic = true },
                transparent = true,
                sidebars = "transparent",
                floats = "transparent",
            },
        },
    },
    {
        "loctvl842/monokai-pro.nvim",
        opts = {
            filter = (function()
                local filters = {
                    "classic",
                    "octagon",
                    "pro",
                    "machine",
                    "ristretto",
                    "spectrum",
                }
                return filters[math.random(#filters)]
            end)(),
            transparent_background = true,
            terminal_colors = true,
        },
    },
    {
        "navarasu/onedark.nvim",
        opts = {
            style = (function()
                local styles = {
                    "dark",
                    "darker",
                    "cool",
                    "deep",
                    "warm",
                    "warmer",
                }
                return styles[math.random(#styles)]
            end)(),
            transparent = true,
            lualine = {
                transparent = true,
            },
        },
    },

    -- file tree
    {
        "nvim-tree/nvim-tree.lua",
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        opts = {
            update_focused_file = {
                enable = true,
                update_cwd = true,
            },
        },
    },

    -- icons, for UI related plugins
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup()
        end,
    },

    -- syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("plugins.configs.treesitter")
        end,
    },

    -- buffer + tab line
    {
        "akinsho/bufferline.nvim",
        event = "BufReadPre",
        config = function()
            require("plugins.configs.bufferline")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup()
        end,
    },

    -- we use cmp plugin only when in insert mode
    -- so lets lazyload it at InsertEnter event, to know all the events check h-events
    -- completion , now all of these plugins are dependent on cmp, we load them after cmp
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            -- cmp sources
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lua",

            -- snippets
            --list of default snippets
            "rafamadriz/friendly-snippets",

            -- snippets engine
            {
                "L3MON4D3/LuaSnip",
                config = function()
                    require("luasnip.loaders.from_vscode").lazy_load()
                end,
            },

            -- autopairs , autocompletes ()[] etc
            {
                "windwp/nvim-autopairs",
                config = function()
                    require("nvim-autopairs").setup()

                    --  cmp integration
                    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                    local cmp = require("cmp")
                    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
                end,
            },
        },
        config = function()
            require("plugins.configs.cmp")
        end,
    },

    -- lsp
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        cmd = { "Mason", "MasonInstall" },
        config = function()
            require("mason").setup()
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = { "lua_ls", "rust_analyzer", "ruff_lsp", "gopls" },
        },
    },

    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("plugins.configs.lspconfig")
        end,
    },

    -- formatting , linting
    {
        "stevearc/conform.nvim",
        lazy = true,
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            local ensure_installed = { "stylua", "prettier", "golines", "goimports", "shfmt" }
            local registry = require("mason-registry")
            for _, name in ipairs(ensure_installed) do
                local package = registry.get_package(name)
                if not package:is_installed() then
                    package:install()
                end
            end
            require("plugins.configs.conform")
        end,
    },

    -- indent lines
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("ibl").setup()
        end,
    },

    -- files finder etc
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = [[ cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && \
			cmake --build build --config Release && cmake --install build --prefix build ]],
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "Telescope",
        config = function()
            require("plugins.configs.telescope")
        end,
    },

    -- git status on signcolumn etc
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("plugins.configs.gitsigns")
        end,
    },

    -- comment plugin
    {
        "numToStr/Comment.nvim",
        lazy = true,
        config = function()
            require("Comment").setup()
        end,
    },

    -- which-key
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {},
        config = function()
            require("which-key").setup()
        end,
    },
    -- floating terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            local Terminal = require("toggleterm.terminal").Terminal
            local lazygit = nil
            vim.keymap.set("n", "<leader>gg", function()
                if lazygit == nil then
                    lazygit =
                        Terminal:new({ cmd = "lazygit", hidden = true, direction = "float", close_on_exit = true })
                end
                lazygit:toggle()
            end, { noremap = true, silent = true })
            local default_terminal = nil
            -- temrinal
            vim.keymap.set("n", "<F12>", function()
                if default_terminal == nil then
                    default_terminal = Terminal:new({
                        direction = "float",
                        -- close_on_exit = true,
                        on_open = function(term)
                            vim.cmd("startinsert!")
                            vim.keymap.set(
                                "n",
                                "q",
                                "<cmd>close<CR>",
                                { noremap = true, silent = true, buffer = term.bufnr }
                            )
                        end,
                    })
                end
                default_terminal:toggle()
            end)
            require("plugins.configs.toggleterm")
        end,
    },
}

require("lazy").setup(plugins, require("plugins.configs.lazy"))
