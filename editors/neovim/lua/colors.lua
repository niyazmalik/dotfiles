for _, group in ipairs({ "Normal", "NormalFloat", "NormalNC", "SignColumn", "EndOfBuffer" }) do
    vim.api.nvim_set_hl(0, group, { bg = "#000000" })
end

vim.api.nvim_set_hl(0, "Pmenu", { bg = "#0b1542", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#414157", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#2a2a2a" })
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#4a4a4a" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#808080", bg = "NONE" })
vim.cmd.highlight("FoldColumn guibg=NONE ctermbg=NONE")
