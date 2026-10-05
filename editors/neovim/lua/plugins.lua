local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "--branch=stable", "https://github.com/folke/lazy.nvim.git", lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()

            vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add file" })
            vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })

            for i = 1, 4 do
                vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end, { desc = "Harpoon file " .. i })
            end
        end,
    },

    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    mappings = {
                        n = { ["q"] = require("telescope.actions").close },
                    },
                },
            })
            vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
            vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
            vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
            vim.keymap.set("n", "<leader>dd", "<cmd>Telescope diagnostics<cr>")
        end,
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
                    vim.keymap.set("n", "<leader>s", vim.diagnostic.open_float, { buffer = args.buf })
                end,
            })
            vim.diagnostic.config({ float = { border = "rounded" } })

            vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
            vim.lsp.config("pyright", {
                before_init = function(_, config)
                    local python = config.root_dir and config.root_dir .. "/.venv/bin/python"
                    if python and vim.uv.fs_stat(python) then
                        config.settings.python.pythonPath = python
                    end
                end,
            })
            vim.lsp.enable({ "ts_ls", "pyright", "gopls" })
        end,
    },

    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                window = {
                    completion = {
                        border = "rounded",
                        scrollbar = false,
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                    },
                    documentation = {
                        border = "rounded",
                        scrollbar = false,
                    },
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                },
            })
        end,
    },
})
