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
        -- treesitter require config() to setup rather than opts
        config = function()
            pcall(function()
                dofile(vim.g.base46_cache .. "syntax")
                dofile(vim.g.base46_cache .. "treesitter")
            end)

            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "go", "python", "rust" },

                highlight = {
                    enable = true,
                    use_languagetree = true,
                },

                indent = { enable = true },
            })
        end,
    },

    {
        "windwp/nvim-autopairs",
        opts = {
            fast_wrap = {},
            disable_filetype = { "TelescopePrompt", "vim" },
        },
    },
    {
        "saghen/blink.compat",
        -- use v2.* for blink.cmp v1.*
        version = "2.*",
        -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
        lazy = true,
        -- make sure to set opts so that lazy.nvim calls blink.compat's setup
        opts = {},
    },
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets", "xieyonn/blink-cmp-dat-word", "xzbdmw/colorful-menu.nvim" },
        version = "1.*",
        opts_extend = { "sources.default" },
        opts = function()
            return require("plugins.configs.blink")
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
        dependencies = { "saghen/blink.cmp" },
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
            "nvim-telescope/telescope-ui-select.nvim",
        },
        cmd = "Telescope",
        opts = function()
            return require("plugins.configs.telescope")
        end,
        config = function(_, opts)
            local telescope = require("telescope")
            telescope.setup(opts)
            telescope.load_extension("ui-select")
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
            -- "rcarriga/nvim-dap-ui",
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
    {
        "igorlfs/nvim-dap-view",
        ---@module 'dap-view'
        ---@type dapview.Config
        opts = {},
    },
    {
        "stevearc/overseer.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        opts = {},
    },
    -- comment plugin enable auto comment for nested typescript/css in .vue file
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            enable_autocmd = false,
        },
    },
    {
        "olimorris/codecompanion.nvim",
        opts = {
            adapters = {
                http = {
                    siliconflow_r1 = function()
                        return require("codecompanion.adapters").extend("deepseek", {
                            name = "siliconflow_r1",
                            url = "https://api.siliconflow.cn/v1/chat/completions",
                            env = {
                                api_key = "DEEPSEEK_API_KEY",
                            },
                            schema = {
                                model = {
                                    default = "deepseek-ai/DeepSeek-R1-0528-Qwen3-8B",
                                    choices = {
                                        ["deepseek-ai/DeepSeek-R1-0528-Qwen3-8B"] = { opts = { can_reason = true } },
                                        "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B",
                                    },
                                },
                            },
                        })
                    end,
                },
            },
            strategies = {
                -- Change the default chat adapter
                chat = {
                    adapter = "siliconflow_r1",
                },
                inline = {
                    adapter = "siliconflow_r1",
                },
            },
            opts = {
                -- Set debug logging
                log_level = "DEBUG",
                language = "Chinese",
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "xiyaowong/transparent.nvim",
        lazy = false,
        opts = {
            extra_groups = {
                "NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
                "NvimTreeNormal", -- NvimTree lost focus
                "NvimTreeNormalNC", -- NvimTree focus
            },
        },
    },
    {
        "folke/sidekick.nvim",
        event = "VeryLazy",
        opts = {
            -- -- 仅使用 CLI 功能，禁用 NES
            -- nes = { enabled = false },
            cli = {
                tools = {
                    coco = {
                        cmd = { "coco" },
                        title = "Coco AI",
                    },
                },
            },
        },
        keys = {
            {
                "<leader>aa",
                function()
                    require("sidekick.cli").toggle()
                end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<leader>as",
                function()
                    require("sidekick.cli").select()
                end,
                -- Or to select only installed tools:
                -- require("sidekick.cli").select({ filter = { installed = true } })
                desc = "Select CLI",
            },
            {
                "<leader>ad",
                function()
                    require("sidekick.cli").close()
                end,
                desc = "Detach a CLI Session",
            },
            {
                "<leader>at",
                function()
                    require("sidekick.cli").send({ msg = "{this}" })
                end,
                mode = { "x", "n" },
                desc = "Send This",
            },
            {
                "<leader>af",
                function()
                    require("sidekick.cli").send({ msg = "{file}" })
                end,
                desc = "Send File",
            },
            {
                "<leader>av",
                function()
                    require("sidekick.cli").send({ msg = "{selection}" })
                end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ap",
                function()
                    require("sidekick.cli").prompt()
                end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
            -- Example of a keybinding to open Claude directly
            {
                "<leader>ac",
                function()
                    require("sidekick.cli").toggle({ name = "coco", focus = true })
                end,
                desc = "Sidekick Toggle Coco, aka trae-cli",
            },
        },
    },
    {
        "nvim-pack/nvim-spectre",
        dependencies = { "nvim-lua/plenary.nvim" }, -- 基础依赖，几乎所有nvim插件都有
        keys = { -- 配置快捷键，开箱即用
            { "<leader>ss", "<cmd>lua require('spectre').open()<CR>", desc = "全局替换-打开面板" },
            {
                "<leader>sw",
                "<cmd>lua require('spectre').open_visual({select_word=true})<CR>",
                desc = "全局替换-匹配当前单词",
            },
        },
        config = function()
            require("spectre").setup({
                open_cmd = "vnew", -- 垂直分屏打开预览面板（默认，推荐）
                live_update = true, -- 实时预览替换结果（核心功能，必开）
                is_insert_mode = true, -- 打开面板后默认进入插入模式，直接输入搜索内容
            })
        end,
    },
}

if require("inneroptions").enable_inner_options() then
    table.insert(
        plugins, -- condeverse
        {
            require("inneroptions").get_inner_plugin_url(),
            config = function()
                require("trae").setup({})
            end,
        }
    )
end

require("lazy").setup(plugins, require("plugins.configs.lazy"))
