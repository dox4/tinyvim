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

    -- NvChad plugins
    {
        "nvchad/base46",
        build = function()
            require("base46").load_all_highlights()
        end,
    },

    {
        "nvchad/ui",
        lazy = false,
        config = function()
            require("nvchad")
        end,
    },

    "nvzone/volt",
    "nvzone/menu",
    { "nvzone/minty", cmd = { "Huefy", "Shades" } },

    -- file tree
    {
        "nvim-tree/nvim-tree.lua",
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        opts = function()
            return require("plugins.configs.nvimtree")
        end,
    },

    -- icons, for UI related plugins
    {
        "nvim-tree/nvim-web-devicons",
        opts = function()
            dofile(vim.g.base46_cache .. "devicons")
            return { override = require("nvchad.icons.devicons") }
        end,
    },

    -- syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = function()
            return require("plugins.configs.treesitter")
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
            "https://codeberg.org/FelipeLema/cmp-async-path.git",

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
                opts = {
                    fast_wrap = {},
                    disable_filetype = { "TelescopePrompt", "vim" },
                },
                config = function(_, opts)
                    require("nvim-autopairs").setup(opts)

                    --  cmp integration
                    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                    local cmp = require("cmp")
                    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
                end,
            },
        },
        opts = function()
            return require("plugins.configs.cmp")
        end,
    },

    -- lsp
    {
        "mason-org/mason.nvim",
        opts = function()
            dofile(vim.g.base46_cache .. "mason")
            return {}
        end,
    },

    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = { "lua_ls", "rust_analyzer", "ruff", "gopls", "vtsls" },
            automatic_enable = { "vtsls" },
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
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
            local ensure_installed = { "prettier", "golines", "goimports", "shfmt" }
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
        opts = {
            indent = { char = "│", highlight = "IblChar" },
            scope = { char = "│", highlight = "IblScopeChar" },
        },
        config = function(_, opts)
            dofile(vim.g.base46_cache .. "blankline")

            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
            require("ibl").setup(opts)

            dofile(vim.g.base46_cache .. "blankline")
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
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        cmd = "Telescope",
        opts = function()
            return require("plugins.configs.telescope")
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

    -- which-key
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" },
        cmd = "WhichKey",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = function()
            dofile(vim.g.base46_cache .. "whichkey")
            return {}
        end,
        config = function()
            require("which-key").setup()
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
    {
        "stevearc/overseer.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        opts = {
        },
    },
}

require("lazy").setup(plugins, require("plugins.configs.lazy"))
