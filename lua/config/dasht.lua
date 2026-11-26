-- Dokumentacja offline (dasht) z poziomu Neovima, w pływającym oknie
local M = {}

-- Docsety przeszukiwane dla danego typu pliku.
-- Nazwy są dopasowywane jako fragment, bez wielkości liter ("python" pasuje do "Python_3").
-- Docsety, których nie masz zainstalowanych, są po prostu pomijane.
M.docsets = {
    python = { "python", "django", "pandas", "numpy", "fastapi", "sqlalchemy" },
    lua = { "lua" },
    sh = { "bash" },
}

local function run(query, docsets)
    if vim.fn.executable("dasht") == 0 then
        return vim.notify("dasht nie jest zainstalowany", vim.log.levels.ERROR)
    end
    if not query or query == "" then
        return
    end

    -- Najpierw sprawdź, czy są wyniki: bez tego przy braku wyników
    -- okno otworzyłoby się i od razu zamknęło
    local args = vim.list_extend({ query }, docsets)
    local check = vim.system(vim.list_extend({ "dasht-query-line" }, args)):wait()
    if check.code ~= 0 or check.stdout == "" then
        local where = #docsets > 0 and table.concat(docsets, ", ") or "wszystkich docsetach"
        return vim.notify("Brak wyników dla „" .. query .. "” w: " .. where, vim.log.levels.WARN)
    end

    require("config.float_term").open(vim.list_extend({ "dasht" }, args))
end

local function filetype_docsets()
    return M.docsets[vim.bo.filetype] or {}
end

-- Słowo pod kursorem
function M.cursor()
    run(vim.fn.expand("<cword>"), filetype_docsets())
end

-- Wpisane zapytanie, w docsetach dla typu pliku
function M.prompt()
    vim.ui.input({ prompt = "dasht: " }, function(query)
        run(query, filetype_docsets())
    end)
end

-- :Dasht zapytanie [docset ...]  (bez docsetów: szukaj we wszystkich)
vim.api.nvim_create_user_command("Dasht", function(opts)
    run(opts.fargs[1], vim.list_slice(opts.fargs, 2))
end, { nargs = "+", desc = "Szukaj w dokumentacji offline (dasht)" })

return M
