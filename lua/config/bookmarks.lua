-- Zakładki z opisem, osobne dla każdego projektu (katalogu roboczego)
local M = {}

local ns = vim.api.nvim_create_namespace("user.bookmarks")
local dir = vim.fn.stdpath("data") .. "/bookmarks"

-- Plik z zakładkami projektu: ~/.local/share/nvim/bookmarks/<ścieżka_projektu>.json
local function store_path()
    local name = vim.fn.getcwd():gsub("[/\\:]", "%%")
    return dir .. "/" .. name .. ".json"
end

local function load()
    local f = io.open(store_path(), "r")
    if not f then
        return {}
    end
    local ok, data = pcall(vim.json.decode, f:read("*a"))
    f:close()
    return ok and data or {}
end

local function save(list)
    vim.fn.mkdir(dir, "p")
    local f = assert(io.open(store_path(), "w"))
    f:write(vim.json.encode(list))
    f:close()
end

local function rel(buf)
    return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
end

-- Znaczki obok numerów linii; extmarki przesuwają się razem z tekstem
local function refresh(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
        return
    end
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    local file, count = rel(buf), vim.api.nvim_buf_line_count(buf)
    for i, b in ipairs(load()) do
        if b.file == file and b.line <= count then
            vim.api.nvim_buf_set_extmark(buf, ns, b.line - 1, 0, {
                id = i,
                sign_text = "»",
                sign_hl_group = "DiagnosticInfo",
            })
        end
    end
end

-- Po zapisie pliku: zaktualizuj numery linii, jeśli kod się przesunął
local function sync(buf)
    local list, file, changed = load(), rel(buf), false
    for i, b in ipairs(list) do
        if b.file == file then
            local pos = vim.api.nvim_buf_get_extmark_by_id(buf, ns, i, {})
            if pos[1] and pos[1] + 1 ~= b.line then
                b.line, changed = pos[1] + 1, true
            end
        end
    end
    if changed then
        save(list)
    end
end

function M.add()
    local buf = vim.api.nvim_get_current_buf()
    local file, line = rel(buf), vim.api.nvim_win_get_cursor(0)[1]
    vim.ui.input({ prompt = "Opis zakładki: " }, function(desc)
        if not desc or desc == "" then
            return
        end
        local list = load()
        for _, b in ipairs(list) do
            if b.file == file and b.line == line then
                b.desc = desc -- ta sama linia: zmień tylko opis
                save(list)
                return refresh(buf)
            end
        end
        table.insert(list, { file = file, line = line, desc = desc })
        save(list)
        refresh(buf)
    end)
end

function M.delete()
    local buf = vim.api.nvim_get_current_buf()
    local file, line = rel(buf), vim.api.nvim_win_get_cursor(0)[1]
    local list, kept = load(), {}
    for _, b in ipairs(list) do
        if not (b.file == file and b.line == line) then
            table.insert(kept, b)
        end
    end
    if #kept == #list then
        return vim.notify("Brak zakładki w tej linii", vim.log.levels.WARN)
    end
    save(kept)
    refresh(buf)
end

function M.list()
    local list = load()
    if #list == 0 then
        return vim.notify("Brak zakładek w tym projekcie", vim.log.levels.INFO)
    end
    local entries = {}
    for _, b in ipairs(list) do
        -- format plik:linia:kolumna: tekst rozumieją podgląd i akcje fzf-lua
        table.insert(entries, string.format("%s:%d:1: %s", b.file, b.line, b.desc))
    end
    local fzf = require("fzf-lua")
    fzf.fzf_exec(entries, {
        prompt = "Zakładki> ",
        previewer = "builtin",
        actions = { ["default"] = fzf.actions.file_edit },
    })
end

function M.setup()
    local group = vim.api.nvim_create_augroup("user.bookmarks", { clear = true })
    vim.api.nvim_create_autocmd("BufReadPost", {
        group = group,
        callback = function(args) refresh(args.buf) end,
    })
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        callback = function(args) sync(args.buf) end,
    })
    vim.api.nvim_create_autocmd("DirChanged", {
        group = group,
        callback = function()
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(b) then refresh(b) end
            end
        end,
    })
end

return M
