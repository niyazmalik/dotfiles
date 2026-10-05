vim.opt.termguicolors = true
vim.opt.fileformats = { "unix", "dos", "mac" }

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ruler = false
vim.opt.laststatus = 0
vim.opt.showtabline = 0
vim.opt.fillchars = { eob = " " }
vim.opt.foldcolumn = "1"
vim.opt.showmode = false
vim.opt.shortmess:append("IWc")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.g.loaded_matchparen = 1
vim.g.netrw_banner = 0

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = "*.txt",
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.keymap.set("n", "l", "<CR>", { buffer = true, remap = true })
        vim.keymap.set("n", "h", "-", { buffer = true, remap = true })
    end,
})

--[[ The cityhotel repos have files with mixed line endings, which Neovim reads as unix
     and paints a ^M on every CRLF line. I hide those on screen only, so the bytes on
     disk stay untouched and git never shows a diff I did not make. ]]
local stray_cr_ns = vim.api.nvim_create_namespace("stray_carriage_returns")

local function has_stray_cr(buf)
    if vim.b[buf].stray_cr == nil then
        local found = false
        if vim.bo[buf].buftype == "" then
            for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
                if line:sub(-1) == "\r" then
                    found = true
                    break
                end
            end
        end
        vim.b[buf].stray_cr = found
    end
    return vim.b[buf].stray_cr
end

vim.api.nvim_set_decoration_provider(stray_cr_ns, {
    on_win = function(_, _, buf)
        return vim.b[buf].stray_cr == true
    end,
    on_line = function(_, _, buf, row)
        local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
        if line and line:sub(-1) == "\r" then
            vim.api.nvim_buf_set_extmark(buf, stray_cr_ns, row, #line - 1, {
                end_col = #line,
                conceal = "",
                ephemeral = true,
            })
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
    group = vim.api.nvim_create_augroup("StrayCarriageReturns", { clear = true }),
    callback = function(args)
        if args.event == "BufReadPost" then
            vim.b[args.buf].stray_cr = nil
        end

        local win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_get_buf(win) ~= args.buf then
            return
        end

        if has_stray_cr(args.buf) then
            vim.wo[win].conceallevel = 3
            vim.wo[win].concealcursor = "nvic"
        else
            vim.wo[win].conceallevel = 0
        end
    end,
})
