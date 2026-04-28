
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>e", "<cmd>Explore<cr>", { desc = "File explorer" })

vim.keymap.set("i", "kj", "<Esc>", { noremap = true })

vim.keymap.set({"i", "s"}, "hh", function()
    require("luasnip").expand()
end, { desc = "Expand snippet" })

vim.keymap.set("n", "<A-j>", "]m", { desc = "Next brace" })
vim.keymap.set("n", "<A-k>", "[m", { desc = "Previous brace" })

vim.keymap.set("i", "<A-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("i", "<A-l>", "<Right>", { desc = "Move right" })

vim.keymap.set('n', '<Tab>', '4l', { noremap = true })
vim.keymap.set('n', '<S-Tab>', '4h', { noremap = true })

vim.keymap.set("n", "<leader>dd", "<cmd>Telescope diagnostics<cr>")

vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })

vim.keymap.set("n", "x", '"_dP')
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") 


vim.keymap.set('n', 'tt', ToggleTerminal, { noremap = true, silent = true })
vim.keymap.set('t', 'tt', ToggleTerminal, { noremap = true, silent = true })

