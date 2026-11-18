-- lazygit w pływającym oknie; proces istnieje tylko, gdy okno jest otwarte
local M = {}

function M.open(cmd)
    cmd = cmd or { "lazygit" }
    if vim.fn.executable(cmd[1]) == 0 then
        return vim.notify(cmd[1] .. " nie jest zainstalowany", vim.log.levels.ERROR)
    end

    local width = math.floor(vim.o.columns * 0.9)
    local height = math.floor(vim.o.lines * 0.85)
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = "minimal",
        border = "rounded",
    })

    vim.fn.jobstart(cmd, {
        term = true,
        on_exit = function()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
            -- przeładuj pliki zmienione przez lazygit (checkout, stash, pull)
            vim.cmd("silent! checktime")
        end,
    })
    vim.cmd.startinsert()
end

return M
