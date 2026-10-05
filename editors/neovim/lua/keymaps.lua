vim.g.mapleader = " "

vim.keymap.set("n", "<leader>e", "<cmd>Explore<cr>", { desc = "File explorer" })
vim.keymap.set("n", "<C-n>", "<C-i>", { desc = "Jump forward" })
vim.keymap.set("i", "kj", "<Esc>")

vim.keymap.set("n", "<A-j>", "]m", { desc = "Next brace" })
vim.keymap.set("n", "<A-k>", "[m", { desc = "Previous brace" })
vim.keymap.set("i", "<A-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("i", "<A-l>", "<Right>", { desc = "Move right" })

vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("n", "<leader>cp", function()
    vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy full file path to clipboard" })

vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")

local term_buf, term_win

local function toggle_terminal()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
        term_win = nil
        return
    end

    if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
        term_buf = vim.api.nvim_create_buf(false, true)
    end

    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.8)
    term_win = vim.api.nvim_open_win(term_buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "single",
    })

    if vim.bo[term_buf].buftype ~= "terminal" then
        vim.fn.jobstart(vim.o.shell, { term = true })
    end
    vim.cmd.startinsert()
end

vim.keymap.set({ "n", "t" }, "tt", toggle_terminal, { silent = true })
