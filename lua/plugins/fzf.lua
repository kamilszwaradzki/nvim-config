return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",

        keys = {
            { "<leader>ff", function() require("fzf-lua").files() end, desc = "Pliki" },
            { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "Szukaj w treści" },
            { "<leader>fw", function() require("fzf-lua").grep_cword() end, desc = "Szukaj słowa pod kursorem" },
            { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Otwarte bufory" },
            { "<leader>fo", function() require("fzf-lua").oldfiles() end, desc = "Ostatnio otwierane" },
            { "<leader>fr", function() require("fzf-lua").resume() end, desc = "Wróć do ostatniego wyszukiwania" },
            { "<leader>fs", function() require("fzf-lua").lsp_document_symbols() end, desc = "Symbole w pliku" },
            { "<leader>fS", function() require("fzf-lua").lsp_workspace_symbols() end, desc = "Symbole w projekcie" },
            { "<leader>fd", function() require("fzf-lua").diagnostics_document() end, desc = "Diagnostyka pliku" },
            { "<leader>fD", function() require("fzf-lua").diagnostics_workspace() end, desc = "Diagnostyka projektu" },
            { "<leader>fh", function() require("fzf-lua").helptags() end, desc = "Pomoc Neovima" },
            { "<leader>fk", function() require("fzf-lua").keymaps() end, desc = "Skróty klawiszowe" },
        },

        -- Code actions (gra, <leader>ca) i wybór konfiguracji debuggera
        -- też idą przez fzf, ale plugin ładuje się dopiero przy pierwszym użyciu
        init = function()
            vim.ui.select = function(...)
                require("lazy").load({ plugins = { "fzf-lua" } })
                return vim.ui.select(...)
            end
        end,

        config = function()
            local fzf = require("fzf-lua")
            fzf.setup({
                "max-perf",
                files = {
                    fd_opts = "--color=never --hidden --type f --type l"
                        .. " --exclude .git --exclude .venv --exclude __pycache__ --exclude node_modules",
                },
                grep = {
                    rg_opts = "--color=never --column --line-number --no-heading --smart-case"
                        .. " --max-columns=4096 --hidden"
                        .. " --glob=!.git --glob=!.venv --glob=!__pycache__ --glob=!node_modules -e",
                },
            })
            fzf.register_ui_select()
        end,
    },
}