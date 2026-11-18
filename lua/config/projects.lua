-- Zapisana lista projektów z dowolnych katalogów
local M = {}

local store = vim.fn.stdpath("data") .. "/projects.json"

local function load()
    local f = io.open(store, "r")
    if not f then
        return {}
    end
    local ok, data = pcall(vim.json.decode, f:read("*a"))
    f:close()
    return ok and data or {}
end

local function save(list)
    table.sort(list)
    local f = assert(io.open(store, "w"))
    f:write(vim.json.encode(list))
    f:close()
end

-- Ścieżka z ~ zamiast /home/użytkownik, krócej na liście
local function short(path)
    return vim.fn.fnamemodify(path, ":~")
end

function M.add()
    local cwd = vim.fn.getcwd()
    local list = load()
    if vim.tbl_contains(list, cwd) then
        return vim.notify("Projekt już jest na liście: " .. short(cwd))
    end
    table.insert(list, cwd)
    save(list)
    vim.notify("Dodano projekt: " .. short(cwd))
end

local function remove(path)
    save(vim.tbl_filter(function(p) return p ~= path end, load()))
end

-- Zamyka bufory i serwery LSP poprzedniego projektu, żeby nie trzymały RAM-u
local function close_current()
    vim.cmd("silent! wall")
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
            pcall(vim.api.nvim_buf_delete, buf, {})
        end
    end
    for _, client in ipairs(vim.lsp.get_clients()) do
        client:stop()
    end
end

function M.switch(path)
    path = vim.fn.expand(path)
    if vim.fn.isdirectory(path) == 0 then
        return vim.notify("Katalog nie istnieje: " .. short(path), vim.log.levels.ERROR)
    end
    close_current()
    vim.cmd.cd(path)
    vim.notify("Projekt: " .. short(path))
    require("fzf-lua").files()
end

function M.pick()
    if #load() == 0 then
        return vim.notify("Lista pusta. Wejdź do projektu i użyj <leader>pa", vim.log.levels.INFO)
    end
    require("fzf-lua").fzf_exec(function(cb)
        for _, p in ipairs(load()) do
            cb(short(p))
        end
        cb(nil)
    end, {
        prompt = "Projekty> ",
        actions = {
            ["default"] = function(sel) M.switch(sel[1]) end,
            -- Ctrl-x: usuń z listy (katalog na dysku zostaje)
            ["ctrl-x"] = {
                fn = function(sel) remove(vim.fn.expand(sel[1])) end,
                reload = true,
            },
        },
    })
end

return M
