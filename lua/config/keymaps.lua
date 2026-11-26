local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Zapis
map("n", "<leader>w", "<cmd>write<cr>")

-- Wyjście
map("n", "<leader>q", "<cmd>quit<cr>")

-- Wyczyść podświetlenie wyszukiwania
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Poruszanie się po oknach
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Przenoszenie zaznaczonych linii
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- LSP: ustawiane dopiero, gdy serwer podłączy się do bufora
-- Domyślne skróty Neovim 0.12 (nie definiujemy ich ponownie):
--   grr referencje, gri implementacja, grn rename, gra code action,
--   gO symbole w pliku, K hover, [d / ]d diagnostyka, <C-s> (insert) sygnatura
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user.lsp", { clear = true }),
    callback = function(event)
        local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
        local opts = { buffer = event.buf, silent = true }

        -- Ruff nie ma sensownego hovera; K obsługuje tylko BasedPyright
        if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end

        -- Natywne completion (dostarcza je BasedPyright)
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
        end

        map("n", "gd", vim.lsp.buf.definition, opts)
        map("n", "<leader>rn", vim.lsp.buf.rename, opts)
        map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        map("n", "<leader>f", function()
            vim.lsp.buf.format({ name = "ruff" })
        end, opts)
        map("n", "<leader>e", vim.diagnostic.open_float, opts)
    end,
})

-- Ręczne wywołanie completion
map("i", "<C-Space>", function()
    vim.lsp.completion.get()
end, { desc = "Trigger LSP completion" })

-- pytest (moduł ładowany dopiero przy pierwszym użyciu)
map("n", "<leader>tn", function() require("config.pytest").nearest() end, { desc = "Test pod kursorem" })
map("n", "<leader>tf", function() require("config.pytest").file() end, { desc = "Testy w pliku" })
map("n", "<leader>ta", function() require("config.pytest").all() end, { desc = "Wszystkie testy" })
map("n", "<leader>tl", function() require("config.pytest").last() end, { desc = "Powtórz ostatni" })
map("n", "<leader>ot", "<cmd>edit TODO.md<cr>", { desc = "Otwórz TODO projektu" })

-- Projekty
map("n", "<leader>pa", function() require("config.projects").add() end, { desc = "Dodaj bieżący katalog do projektów" })
map("n", "<leader>pp", function() require("config.projects").pick() end, { desc = "Przełącz projekt" })

-- Zakładki
map("n", "<leader>ba", function() require("config.bookmarks").add() end, { desc = "Dodaj zakładkę" })
map("n", "<leader>bd", function() require("config.bookmarks").delete() end, { desc = "Usuń zakładkę" })
map("n", "<leader>bl", function() require("config.bookmarks").list() end, { desc = "Lista zakładek" })

-- Git
map("n", "<leader>gg", function() require("config.float_term").open({ "lazygit" }) end, { desc = "lazygit" })
map("n", "<leader>gs", function() require("fzf-lua").git_status() end, { desc = "Git status" })
map("n", "<leader>gc", function() require("fzf-lua").git_commits() end, { desc = "Historia projektu" })
map("n", "<leader>gC", function() require("fzf-lua").git_bcommits() end, { desc = "Historia pliku" })
map("n", "<leader>gb", function() require("fzf-lua").git_branches() end, { desc = "Gałęzie" })

-- Podgląd Markdowna w glow: szerokie tabele przewijasz strzałkami ←/→, q zamyka
map("n", "<leader>mp", function()
    if vim.bo.filetype ~= "markdown" then
        return vim.notify("To nie jest plik Markdown", vim.log.levels.WARN)
    end
    if vim.fn.executable("glow") == 0 then
        return vim.notify("glow nie jest zainstalowany", vim.log.levels.ERROR)
    end
    vim.cmd("silent! write") -- podgląd pokazuje plik z dysku, więc najpierw zapis
    local file = vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
    require("config.float_term").open({ "sh", "-c", "PAGER='less -RS' glow -p -w 0 " .. file })
end, { desc = "Podgląd Markdown (glow)" })

-- Dokumentacja offline (dasht)
map("n", "<leader>K", function() require("config.dasht").cursor() end, { desc = "Dokumentacja: słowo pod kursorem" })
map("n", "<leader>ks", function() require("config.dasht").prompt() end, { desc = "Dokumentacja: szukaj" })
