vim.opt.hidden = true
vim.opt.termguicolors = true

-- Force black background
vim.api.nvim_set_hl(0, 'Normal', { bg = '#000000' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#000000' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#000000' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = '#000000' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = '#000000' })

-- Fix popup menu colors
vim.api.nvim_set_hl(0, 'Pmenu', { bg = '#0b1542', fg = '#ffffff' })
vim.api.nvim_set_hl(0, 'PmenuSel', { bg = '#414157', fg = '#ffffff' })
vim.api.nvim_set_hl(0, 'PmenuSbar', { bg = '#2a2a2a' })
vim.api.nvim_set_hl(0, 'PmenuThumb', { bg = '#4a4a4a' })

vim.opt.ruler = false

-- UI settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 0
vim.opt.signcolumn = "auto"
vim.opt.scrolloff = 0
vim.opt.fillchars = { eob = " " }

-- Disable bracket matching highlight
vim.g.loaded_matchparen = 1

-- Left margin padding
vim.opt.foldcolumn = "1"
vim.cmd([[highlight FoldColumn guibg=NONE ctermbg=NONE]])

-- Hide mode text and messages
vim.opt.showmode = false
vim.opt.shortmess:append("IWc")

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function()
        vim.opt_local.tabstop = 6
        vim.opt_local.shiftwidth = 6
    end,
})

-- Terminal toggle function (floating centered version)
local term_buf = nil
local term_win = nil

function ToggleTerminal()
    -- If terminal window exists and is valid, close it
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
        term_win = nil
        return
    end

    -- If terminal buffer doesn't exist or isn't valid, create new one
    if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
        term_buf = vim.api.nvim_create_buf(false, true)
    end

    -- Get editor dimensions
    local width = vim.o.columns
    local height = vim.o.lines

    -- Calculate floating window size (80% width, 60% height)
    local win_width = math.floor(width * 0.6)
    local win_height = math.floor(height * 0.8)

    -- Calculate center position
    local row = math.floor((height - win_height) / 2)
    local col = math.floor((width - win_width) / 2)

    -- Floating window options
    local opts = {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'single',
    }

    -- Open floating window
    term_win = vim.api.nvim_open_win(term_buf, true, opts)

    -- Set window-local options
    vim.api.nvim_win_set_option(term_win, 'winblend', 0)

    -- Start terminal if it's a new buffer
    if vim.api.nvim_buf_line_count(term_buf) == 1 and vim.api.nvim_buf_get_lines(term_buf, 0, -1, false)[1] == '' then
        vim.fn.termopen(vim.o.shell)
    end

    -- Enter insert mode
    vim.cmd('startinsert')
end

-- Set border color to grey
vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#808080', bg = 'NONE' })

-- Netrw settings
vim.g.netrw_banner = 0

-- No line numbers for txt files
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = "*.txt",
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

-- Netrw keymaps
vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.keymap.set("n", "l", "<CR>", { buffer = true, remap = true })
        vim.keymap.set("n", "h", "-", { buffer = true, remap = true })
    end,
})
