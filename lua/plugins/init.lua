---@param config {args?:string[]|fun():string[]?}
local function get_args(config)
    local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
    config = vim.deepcopy(config)
    ---@cast args string[]
    config.args = function()
        local new_args = vim.fn.input("Run with args: ", table.concat(args, " ")) --[[@as string]]
        return vim.split(vim.fn.expand(new_args) --[[@as string]], " ")
    end
    return config
end
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
    {
        "sainnhe/gruvbox-material",
        config = function()
            vim.g.gruvbox_material_enable_italic = true
            vim.g.gruvbox_material_enable_bold = 1
            vim.g.gruvbox_material_background = "hard"
            vim.g.gruvbox_material_transparent_background = 2
            vim.g.gruvbox_material_ui_contrast = "hight"
            vim.g.gruvbox_material_better_performance = true
        end,
    },

    -- file tree
    {
        "nvim-tree/nvim-tree.lua",
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        config = function()
            require("plugins.configs.nvimtree")
        end,
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
            require("lualine").setup({
                sections = {
                    lualine_c = { { "filename", path = 1 } },
                },
            })
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
            ensure_installed = { "lua_ls", "rust_analyzer", "ruff", "gopls" },
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
            require("plugins.configs.toggleterm")
        end,
    },
    -- auto save
    {
        -- lua
        "0x00-ketsu/autosave.nvim",
        -- lazy-loading on events
        event = { "InsertLeave", "TextChanged" },
        config = function()
            require("autosave").setup({
                enable = true,
                prompt_message = function()
                    return "autosave: " .. vim.fn.expand("%:p:.") .. " saved at " .. vim.fn.strftime("%H:%M:%S")
                end,
            })
        end,
    },
    -- outline
    {
        "stevearc/aerial.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("aerial").setup({
                lazy_load = false,
                -- open_automatic = true,
                on_attach = function(bufnr)
                    vim.keymap.set("n", "[a", "<cmd>AerialPrev<CR>", { buffer = bufnr })
                    vim.keymap.set("n", "]a", "<cmd>AerialNext<CR>", { buffer = bufnr })
                end,
            })
        end,
    },
    -- dap
    {
        "mfussenegger/nvim-dap",
        recommended = true,
        desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras in LazyVim)",

        dependencies = {
            "rcarriga/nvim-dap-ui",
            -- virtual text for the debugger
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {},
            },
        },

    	-- stylua: ignore
    	keys = {
    	    { "<leader>d", "", desc = "+debug", mode = {"n", "v"} },
    	    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
    	    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    	    { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
    	    { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
    	    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
    	    { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
    	    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
    	    { "<leader>dj", function() require("dap").down() end, desc = "Down" },
    	    { "<leader>dk", function() require("dap").up() end, desc = "Up" },
    	    { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
    	    { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
    	    { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
    	    { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
    	    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    	    { "<leader>ds", function() require("dap").session() end, desc = "Session" },
    	    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    	    { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    	},

        config = function()
            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

            -- setup dap config by VsCode launch.json file
            local vscode = require("dap.ext.vscode")
            local json = require("plenary.json")
            vscode.json_decode = function(str)
                return vim.json.decode(json.json_strip_comments(str))
            end
            require("plugins.configs.dap")
        end,
    },

    -- fancy UI for the debugger
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
    	-- stylua: ignore
    	keys = {
    	    { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
    	    { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
    	},
        opts = {
            layouts = {
                {
                    -- You can change the order of elements in the sidebar
                    elements = {
                        -- Provide IDs as strings or tables with "id" and "size" keys
                        {
                            id = "scopes",
                            size = 0.25, -- Can be float or integer > 1
                        },
                        { id = "breakpoints", size = 0.25 },
                        { id = "stacks", size = 0.25 },
                        { id = "watches", size = 0.25 },
                    },
                    size = 40,
                    position = "right", -- Can be "left" or "right"
                },
                {
                    elements = {
                        "repl",
                        "console",
                    },
                    size = 10,
                    position = "bottom", -- Can be "bottom" or "top"
                },
            },
        },
        config = function(_, opts)
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup(opts)
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open({})
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close({})
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close({})
            end
        end,
    },
}

require("lazy").setup(plugins, require("plugins.configs.lazy"))
