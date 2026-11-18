return {
    {
        "neovim/nvim-lspconfig",
        lazy = false, -- to tylko definicje serwerów; enable() musi wykonać się zawsze

        config = function()
            vim.lsp.config("basedpyright", {
                settings = {
                    basedpyright = {
                        analysis = {
                            typeCheckingMode = "basic",
                            diagnosticMode = "openFilesOnly",
                            autoSearchPaths = true,
                        },
                    },
                },
            })

            vim.lsp.config("ruff", {
                -- BasedPyright obsługuje tylko UTF-16, więc Ruff musi użyć tego samego
                capabilities = {
                    general = {
                        positionEncodings = { "utf-16" },
                    },
                },
                init_options = {
                    settings = {
                        logLevel = "warn",
                    },
                },
            })

            vim.lsp.enable({ "basedpyright", "ruff" })
        end,
    },
}
