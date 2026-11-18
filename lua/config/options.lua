local opt = vim.opt

-- Numeracja linii
opt.number = true
opt.relativenumber = true

-- Wcięcia
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

-- Wyszukiwanie
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Interfejs
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.wrap = false

-- Pliki
opt.undofile = true
opt.swapfile = false
opt.backup = false

-- Wydajność
opt.updatetime = 250
opt.timeoutlen = 400
opt.lazyredraw = true

-- Schowek
opt.clipboard = "unnamedplus"

-- Native LSP completion
vim.opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }
vim.opt.pumheight = 8

-- Foldy dostępne, ale pliki otwierają się rozwinięte
opt.foldlevel = 99

-- Przeładuj plik, gdy zmieni go inny program (np. Claude Code)
opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    group = vim.api.nvim_create_augroup("user.autoread", { clear = true }),
    command = "silent! checktime",
})