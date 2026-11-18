-- Lekki runner pytest: wynik w terminalu na dole ekranu, bez pluginów
local M = {}

local last_args = nil
local term_win = nil

-- Pytest z .venv projektu, jeśli istnieje; inaczej z PATH
local function pytest_cmd()
    local venv = vim.fn.getcwd() .. "/.venv/bin/pytest"
    if vim.fn.executable(venv) == 1 then
        return { venv }
    end
    return { "pytest" }
end

-- Szuka w górę od kursora najbliższej funkcji test_* i ewentualnej klasy Test*
local function nearest_node_id()
    local file = vim.fn.expand("%:.")
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(0, 0, lnum, false)

    for i = #lines, 1, -1 do
        local indent, name = lines[i]:match("^(%s*)async%s+def%s+(test_[%w_]*)")
        if not name then
            indent, name = lines[i]:match("^(%s*)def%s+(test_[%w_]*)")
        end
        if name then
            -- metoda w klasie: szukamy klasy z mniejszym wcięciem
            if #indent > 0 then
                for j = i - 1, 1, -1 do
                    local cindent, cname = lines[j]:match("^(%s*)class%s+(Test[%w_]*)")
                    if cname and #cindent < #indent then
                        return file .. "::" .. cname .. "::" .. name
                    end
                end
            end
            return file .. "::" .. name
        end
    end
    return nil
end

local function run(args)
    last_args = args
    -- zamknij poprzednie okno z wynikami
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
    end

    local cmd = vim.list_extend(pytest_cmd(), args)
    vim.cmd("botright 12new")
    term_win = vim.api.nvim_get_current_win()
    vim.fn.jobstart(cmd, { term = true })
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true })
    vim.cmd("normal! G")
    vim.cmd("wincmd p") -- kursor wraca do kodu
end

function M.nearest()
    local id = nearest_node_id()
    if not id then
        vim.notify("Brak funkcji test_* nad kursorem", vim.log.levels.WARN)
        return
    end
    run({ id, "-q" })
end

function M.file()
    run({ vim.fn.expand("%:."), "-q" })
end

function M.all()
    run({ "-q" })
end

function M.last()
    if not last_args then
        vim.notify("Nie uruchamiano jeszcze testów", vim.log.levels.WARN)
        return
    end
    run(last_args)
end

return M
