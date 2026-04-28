vim.deprecate = function() end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "--branch=stable", lazyrepo, lazypath
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

            vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
            vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
            vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
            vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
        end,
    },

    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
    },

    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },

    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
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
        end,
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")
              vim.api.nvim_create_autocmd("LspAttach", {
                  callback = function(args)
                      local opts = { buffer = args.buf }
                      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                      vim.keymap.set("n", "<leader>s", vim.diagnostic.open_float, opts)
                      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
                  end,
              })
            vim.diagnostic.config({
                float = {
                    border = "rounded",  -- or "single", "double", "solid"
                }
            })
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            lspconfig.tsserver.setup({ capabilities = capabilities })
            lspconfig.pyright.setup({ capabilities = capabilities })
        end,
    },

      {
          "hrsh7th/nvim-cmp",
          dependencies = {
              "hrsh7th/cmp-nvim-lsp",
              "hrsh7th/cmp-buffer",
              "hrsh7th/cmp-path",
              "L3MON4D3/LuaSnip",
              "saadparwaiz1/cmp_luasnip",
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
                  snippet = {
                      expand = function(args)
                          require("luasnip").lsp_expand(args.body)
                      end,
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

    {
        "lewis6991/gitsigns.nvim",
        config = function()
            local gs = require("gitsigns")
            local inline_all_ns = vim.api.nvim_create_namespace("gitsigns_inline_all_hunks")
            local inline_all_visible = {}
            local staged_inline_ns = vim.api.nvim_create_namespace("gitsigns_staged_inline_hunks")
            local staged_inline_visible = {}

            gs.setup({
                signcolumn = false,
            })

            local function toggle_all_hunks_inline()
                local bufnr = vim.api.nvim_get_current_buf()
                if inline_all_visible[bufnr] then
                    vim.api.nvim_buf_clear_namespace(bufnr, inline_all_ns, 0, -1)
                    inline_all_visible[bufnr] = false
                    return
                end

                local hunks = gs.get_hunks(bufnr)
                if not hunks or #hunks == 0 then
                    vim.notify("No unstaged changes for this file.", vim.log.levels.INFO)
                    return
                end

                vim.api.nvim_buf_clear_namespace(bufnr, inline_all_ns, 0, -1)

                for _, hunk in ipairs(hunks) do
                    local virt_lines = {}
                    for _, line in ipairs(hunk.lines or {}) do
                        local prefix = line:sub(1, 1)
                        local hl = "Comment"
                        if prefix == "+" then
                            hl = "DiffAdd"
                        elseif prefix == "-" then
                            hl = "DiffDelete"
                        end
                        table.insert(virt_lines, { { line, hl } })
                    end

                    if #virt_lines > 0 then
                        local anchor = 0
                        if hunk.added and hunk.added.start and hunk.added.start > 0 then
                            anchor = hunk.added.start - 1
                        elseif hunk.removed and hunk.removed.start and hunk.removed.start > 0 then
                            anchor = hunk.removed.start - 1
                        end
                        vim.api.nvim_buf_set_extmark(bufnr, inline_all_ns, anchor, 0, {
                            virt_lines = virt_lines,
                            virt_lines_above = true,
                        })
                    end
                end

                inline_all_visible[bufnr] = true
            end

            local function git_root_for_current_buffer()
                local file = vim.api.nvim_buf_get_name(0)
                local start_dir = file ~= "" and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()
                local root = vim.fn.systemlist({ "git", "-C", start_dir, "rev-parse", "--show-toplevel" })
                if vim.v.shell_error ~= 0 or not root[1] then
                    return nil
                end
                return root[1]
            end

            local function collect_changed_files(mode)
                local root = git_root_for_current_buffer()
                if not root then
                    vim.notify("Not inside a git repository", vim.log.levels.WARN)
                    return nil
                end

                local lines = {}
                if mode == "staged" then
                    lines = vim.fn.systemlist({ "git", "-C", root, "diff", "--cached", "--name-only" })
                elseif mode == "unstaged" then
                    local modified = vim.fn.systemlist({ "git", "-C", root, "diff", "--name-only" })
                    local untracked = vim.fn.systemlist({ "git", "-C", root, "ls-files", "--others", "--exclude-standard" })
                    for _, p in ipairs(modified) do
                        table.insert(lines, p)
                    end
                    for _, p in ipairs(untracked) do
                        table.insert(lines, p)
                    end
                else
                    local status = vim.fn.systemlist({ "git", "-C", root, "status", "--porcelain" })
                    for _, line in ipairs(status) do
                        local path = line:sub(4)
                        if path:find(" -> ", 1, true) then
                            path = path:match(" -> (.+)$") or path
                        end
                        if path ~= "" then
                            table.insert(lines, path)
                        end
                    end
                end

                local seen = {}
                local files = {}
                for _, p in ipairs(lines) do
                    if p ~= "" and not seen[p] then
                        seen[p] = true
                        table.insert(files, root .. "/" .. p)
                    end
                end
                table.sort(files)
                return files
            end

            local function pick_changed_files(mode)
                local files = collect_changed_files(mode)
                if not files then
                    return
                end
                if #files == 0 then
                    vim.notify("No " .. mode .. " changed files", vim.log.levels.INFO)
                    return
                end

                local pickers = require("telescope.pickers")
                local finders = require("telescope.finders")
                local conf = require("telescope.config").values
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")

                pickers.new({}, {
                    prompt_title = "Git " .. mode .. " files",
                    finder = finders.new_table({
                        results = files,
                    }),
                    sorter = conf.generic_sorter({}),
                    attach_mappings = function(prompt_bufnr, _)
                        actions.select_default:replace(function()
                            local entry = action_state.get_selected_entry()
                            actions.close(prompt_bufnr)
                            if entry and entry[1] then
                                vim.cmd("edit " .. vim.fn.fnameescape(entry[1]))
                            end
                        end)
                        return true
                    end,
                }):find()
            end

            local function toggle_staged_hunks_inline()
                local bufnr = vim.api.nvim_get_current_buf()
                if staged_inline_visible[bufnr] then
                    vim.api.nvim_buf_clear_namespace(bufnr, staged_inline_ns, 0, -1)
                    staged_inline_visible[bufnr] = false
                    return
                end

                local root = git_root_for_current_buffer()
                local file = vim.api.nvim_buf_get_name(bufnr)
                if not root or file == "" then
                    vim.notify("Open a file inside a git repository", vim.log.levels.WARN)
                    return
                end

                local relpath = file:gsub("^" .. vim.pesc(root .. "/"), "")
                local diff = vim.fn.systemlist({ "git", "-C", root, "--no-pager", "diff", "--cached", "--no-color", "-U0", "--", relpath })
                if #diff == 0 then
                    vim.notify("No staged changes for this file.", vim.log.levels.INFO)
                    return
                end

                vim.api.nvim_buf_clear_namespace(bufnr, staged_inline_ns, 0, -1)

                local anchor = nil
                local virt_lines = {}
                local function flush_hunk()
                    if anchor and #virt_lines > 0 then
                        vim.api.nvim_buf_set_extmark(bufnr, staged_inline_ns, math.max(anchor - 1, 0), 0, {
                            virt_lines = virt_lines,
                            virt_lines_above = true,
                        })
                    end
                end

                for _, line in ipairs(diff) do
                    if vim.startswith(line, "@@") then
                        flush_hunk()
                        virt_lines = {}
                        local removed_start, added_start = line:match("^@@ %-(%d+),?%d* %+(%d+),?%d* @@")
                        anchor = tonumber(added_start) or tonumber(removed_start) or 1
                    elseif vim.startswith(line, "+") and not vim.startswith(line, "+++") then
                        table.insert(virt_lines, { { line, "DiffAdd" } })
                    elseif vim.startswith(line, "-") and not vim.startswith(line, "---") then
                        table.insert(virt_lines, { { line, "DiffDelete" } })
                    end
                end
                flush_hunk()

                staged_inline_visible[bufnr] = true
            end

            vim.keymap.set("n", "<leader>gt", gs.toggle_signs, { desc = "Toggle git signs" })
            vim.keymap.set("n", "<leader>gd", function()
                vim.cmd("Gitsigns diffthis")
            end, { desc = "Diff current file" })
            vim.keymap.set("n", "<leader>ga", toggle_all_hunks_inline, { desc = "Toggle all hunks inline" })
            vim.keymap.set("n", "<leader>gA", toggle_staged_hunks_inline, { desc = "Toggle staged hunks inline" })
            vim.keymap.set("n", "<leader>gf", function()
                pick_changed_files("all")
            end, { desc = "Pick all changed files" })
            vim.keymap.set("n", "<leader>gS", function()
                pick_changed_files("staged")
            end, { desc = "Pick staged files" })
            vim.keymap.set("n", "<leader>gU", function()
                pick_changed_files("unstaged")
            end, { desc = "Pick unstaged files" })

            vim.keymap.set("n", "]h", gs.next_hunk, { desc = "Next hunk" })
            vim.keymap.set("n", "[h", gs.prev_hunk, { desc = "Prev hunk" })
            vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
            vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
            vim.keymap.set("n", "<leader>hb", function()
                gs.blame_line({ full = true })
            end, { desc = "Blame line" })
        end,
    },
})
