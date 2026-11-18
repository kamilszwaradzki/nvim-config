return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,       -- plugin nie wspiera lazy-loadingu
        build = ":TSUpdate",

        config = function()
            -- Tylko to, czego używasz. lua, vim, vimdoc, markdown, query i c
            -- są wbudowane w Neovim 0.12, więc ich nie instalujemy.
            require("nvim-treesitter").install({
                "python",
                "htmldjango", -- szablony Django
                "toml",       -- pyproject.toml
                "json",
                "yaml",       -- docker-compose, CI
                "bash",
                "dockerfile",
            })

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("user.treesitter", { clear = true }),
                callback = function(args)
                    -- pcall: dla typów plików bez parsera po prostu nic nie rób
                    if not pcall(vim.treesitter.start, args.buf) then
                        return
                    end
                    vim.wo[0][0].foldmethod = "expr"
                    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                end,
            })
        end,
    },
}