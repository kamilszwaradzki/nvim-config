return {
    {
        "mfussenegger/nvim-dap",
        dependencies = { "mfussenegger/nvim-dap-python" },

        -- Ładowane dopiero przy pierwszym użyciu skrótu: zero kosztu, gdy nie debugujesz
        keys = {
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Breakpoint" },
            { "<leader>dB", function()
                require("dap").set_breakpoint(vim.fn.input("Warunek: "))
            end, desc = "Breakpoint warunkowy" },
            { "<leader>dc", function() require("dap").continue() end, desc = "Start / dalej" },
            { "<leader>dn", function() require("dap").step_over() end, desc = "Następna linia" },
            { "<leader>di", function() require("dap").step_into() end, desc = "Wejdź do funkcji" },
            { "<leader>do", function() require("dap").step_out() end, desc = "Wyjdź z funkcji" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "REPL" },
            { "<leader>dq", function() require("dap").terminate() end, desc = "Zakończ" },
            { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Wartość pod kursorem" },
            { "<leader>ds", function()
                local w = require("dap.ui.widgets")
                w.centered_float(w.scopes)
            end, desc = "Zmienne lokalne" },
            { "<leader>dt", function() require("dap-python").test_method() end, desc = "Debuguj test" },
            { "<leader>dT", function() require("dap-python").test_class() end, desc = "Debuguj klasę testów" },
        },

        config = function()
            local dap = require("dap")
            local dap_python = require("dap-python")

            dap_python.setup(vim.fn.expand("~/.local/share/debugpy/bin/python"))
            dap_python.test_runner = "pytest"

            -- Django
            table.insert(dap.configurations.python, {
                type = "python",
                request = "launch",
                name = "Django: runserver",
                program = "${workspaceFolder}/manage.py",
                args = { "runserver", "--noreload" },
                django = true,
                justMyCode = true,
            })

            -- FastAPI (popraw "app.main:app" na ścieżkę do swojej aplikacji)
            table.insert(dap.configurations.python, {
                type = "python",
                request = "launch",
                name = "FastAPI: uvicorn",
                module = "uvicorn",
                args = { "app.main:app", "--port", "8000" },
                justMyCode = true,
            })

            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })
        end,
    },
}