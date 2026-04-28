-- Custom C++ highlight groups (just definitions, harmless globally)
vim.api.nvim_set_hl(0, "CppBlue", { fg = "#82acfa" })
vim.api.nvim_set_hl(0, "CppPink", { fg = "#ff85ff" })
vim.api.nvim_set_hl(0, "CppCyan", { fg = "#51c7d6" })
vim.api.nvim_set_hl(0, "CppYellow", { fg = "#ffec96" })
vim.api.nvim_set_hl(0, "CppRed", { fg = "#fc5365" })
vim.api.nvim_set_hl(0, "CppWhite", { fg = "#d4d4d4" })
vim.api.nvim_set_hl(0, "CppGreen", { fg = "#6efa7a" })
vim.api.nvim_set_hl(0, "CppGolden", { fg = "#ffaa00" })

local function apply_cpp_colors()
    vim.fn.clearmatches()

    -- Priority 5: Regular identifiers
    vim.fn.matchadd("CppWhite", "\\<[a-zA-Z_][a-zA-Z0-9_]*\\>", 5)

    -- Priority 10: Operators and braces
    vim.fn.matchadd("CppYellow", "[+\\-*/%=<>!&|^~?:]\\+", 10)
    vim.fn.matchadd("CppYellow", "[(){}\\[\\];,.]", 10)
    vim.fn.matchadd("CppYellow", "<<\\|>>\\|&&\\|||\\|==\\|!=\\|<=\\|>=\\|++\\|--\\|->\\|::", 10)

    -- Priority 15: Numbers
    vim.fn.matchadd("CppCyan", [[\<\d\+\(u\|U\|l\|L\|ul\|uL\|Ul\|UL\|ll\|LL\|ull\|ULL\|llu\|LLU\)\?\>]], 15)
    vim.fn.matchadd("CppCyan", [[\<0x[0-9A-Fa-f]\+\(u\|U\|l\|L\|ll\|LL\|ull\|ULL\)\?\>]], 15)
    vim.fn.matchadd("CppCyan", [[\<\d\+\.\d*\([eE][+-]\?\d\+\)\?[fFlL]\?\>]], 15)
    vim.fn.matchadd("CppCyan", [[\<\d\+[eE][+-]\?\d\+[fFlL]\?\>]], 15)

    -- Priority 20: Keywords and types
    local cpp_keywords = {
        "using", "namespace", "short", "unsigned", "long", "double", "bool",
        "true", "false", "char", "auto", "enum", "class", "struct", "return",
        "template", "typename", "const", "static", "void", "for", "while",
        "if", "else", "switch", "case", "break", "continue", "do", "goto",
        "sizeof", "typedef", "public", "private", "protected", "virtual",
        "friend", "inline", "explicit", "operator", "new", "delete", "this",
        "nullptr", "signed", "decltype", "throw"
    }

    local cpp_constants = {
        "INT_MAX", "INT_MIN", "LONG_MAX", "LONG_MIN", "LLONG_MAX", "LLONG_MIN",
        "UINT_MAX", "ULONG_MAX", "ULLONG_MAX", "CHAR_MAX", "CHAR_MIN",
        "SHRT_MAX", "SHRT_MIN", "FLT_MAX", "FLT_MIN", "DBL_MAX", "DBL_MIN",
        "LDBL_MAX", "LDBL_MIN", "SIZE_MAX", "PTRDIFF_MAX", "PTRDIFF_MIN"
    }

    local cpp_types = {
        "int", "int8_t", "int16_t", "int32_t", "int64_t",
        "uint8_t", "uint16_t", "uint32_t", "uint64_t",
        "float", "wchar_t", "char16_t", "char32_t",
        "array", "vector", "list", "forward_list", "stack", "queue",
        "priority_queue", "set", "multiset", "unordered_set", "unordered_multiset",
        "map", "multimap", "unordered_map", "unordered_multimap", "bitset",
        "Color", "Direction", "Container", "Compare", "Args", "Head", "Tail",
        "Fun", "Fenwick",
    }

    vim.fn.matchadd("CppBlue", "\\<\\(" .. table.concat(cpp_keywords, "\\|") .. "\\)\\>", 20)
    vim.fn.matchadd("CppBlue", "\\<\\(" .. table.concat(cpp_constants, "\\|") .. "\\)\\>", 20)
    vim.fn.matchadd("CppPink", "\\<\\(" .. table.concat(cpp_types, "\\|") .. "\\)\\>", 20)

    -- Priority 25: Strings
    vim.fn.matchadd("CppGreen", [["[^"]*"]], 25)
    vim.fn.matchadd("CppGreen", [['[^']*']], 25)

    -- Priority 30: Header-specific identifiers
    local stl_containers = {
        "vector", "map", "set", "queue", "stack", "list", "array", "bitset"
    }

    vim.fn.matchadd("CppWhite", "<\\zs\\(" .. table.concat(stl_containers, "\\|") .. "\\)\\ze>", 30)

    local angle_bracket_types = {
        "int", "int8_t", "int16_t", "int32_t", "int64_t",
        "uint8_t", "uint16_t", "uint32_t", "uint64_t",
        "float", "double", "long", "short", "char", "bool",
        "wchar_t", "char16_t", "char32_t"
    }

    vim.fn.matchadd("CppGreen", "<\\s*\\(" .. table.concat(angle_bracket_types, "\\|") .. "\\)\\s*>", 30)

    -- Priority 35: Comments and preprocessor
    local preprocessor_keywords = {
        "include", "ifndef", "ifdef", "endif", "pragma", "error", "warning",
        "else", "elif", "undef", "define",
    }

    local pattern = "^\\s*#\\s*\\(" .. table.concat(preprocessor_keywords, "\\|") .. "\\)\\>"

    vim.fn.matchadd("CppRed", pattern, 35)
    vim.fn.matchadd("CppRed", "#\\ze\\w", 35)

    -- Priority 35: Comments
    vim.fn.matchadd("CppRed", "//.*$", 35)
    vim.fn.matchadd("CppRed", "/\\*[^*]*\\*/", 35)
end

local function remove_cpp_colors()
    vim.fn.clearmatches()
end

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
    callback = function()
        if vim.bo.filetype == "cpp" then
            apply_cpp_colors()
        else
            remove_cpp_colors()
        end
    end,
})
