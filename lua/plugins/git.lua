return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- zmiany oznaczane kolorem numeru linii, nie znaczkiem:
            -- kolumna znaków zostaje dla E/W z LSP i » z zakładek
            signcolumn = false,
            numhl = true,

            on_attach = function(buf)
                local gs = require("gitsigns")
                local function map(lhs, rhs, desc)
                    vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
                end

                map("]h", function() gs.nav_hunk("next") end, "Następna zmiana")
                map("[h", function() gs.nav_hunk("prev") end, "Poprzednia zmiana")
                map("<leader>hp", gs.preview_hunk, "Podgląd zmiany")
                map("<leader>hs", gs.stage_hunk, "Stage zmiany")
                map("<leader>hr", gs.reset_hunk, "Cofnij zmianę")
                map("<leader>hb", function() gs.blame_line({ full = true }) end, "Blame linii")
                map("<leader>hd", gs.diffthis, "Diff pliku")
            end,
        },
    },
}