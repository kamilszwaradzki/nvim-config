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