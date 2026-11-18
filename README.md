# nvim-config

Lightweight Neovim setup for Python development (Django, Django REST Framework, FastAPI, SQLAlchemy, Pydantic, pytest).

Built for low-spec hardware (tested on a laptop with 4 GB RAM): native Neovim 0.12 features first, no Mason, no Neovim distribution, only four plugins.

## Features

| Area | Tool |
|---|---|
| Language server, type checking | [BasedPyright](https://github.com/DetachHead/basedpyright) via native `vim.lsp.config` / `vim.lsp.enable` |
| Linting, formatting, import sorting | [Ruff](https://github.com/astral-sh/ruff) (`ruff server`) |
| Completion | native `vim.lsp.completion` (no nvim-cmp) |
| Syntax highlighting, folding | [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (`main` branch) |
| Debugging | [nvim-dap](https://github.com/mfussenegger/nvim-dap) + [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python) + debugpy |
| Running tests | small built-in pytest runner (`lua/config/pytest.lua`) |
| Fuzzy finding | [fzf-lua](https://github.com/ibhagwan/fzf-lua) (`max-perf` profile) |
| Project switching | small built-in module (`lua/config/projects.lua`), saved list of paths |
| Bookmarks with descriptions | small built-in module (`lua/config/bookmarks.lua`), per project |
| Plugin manager | [lazy.nvim](https://github.com/folke/lazy.nvim) |

## Requirements

- Neovim **0.12+**
- [uv](https://github.com/astral-sh/uv)
- `git`, `curl`, `tar`, a C compiler (`gcc`)
- [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/releases) **0.26.1+** (Debian stable ships an older version, so use the release binary)
- `fzf`, `ripgrep`, `fd`, `bat`

### Install external tools (Debian)

```bash
# system packages
sudo apt install git curl tar gcc fzf ripgrep fd-find bat

# Python tooling (installed to ~/.local/bin)
uv tool install basedpyright
uv tool install ruff

# debugpy in its own venv, independent of project venvs
uv venv ~/.local/share/debugpy
uv pip install --python ~/.local/share/debugpy/bin/python debugpy

# tree-sitter CLI
curl -fLO https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz
gunzip tree-sitter-linux-x64.gz
chmod +x tree-sitter-linux-x64
mv tree-sitter-linux-x64 ~/.local/bin/tree-sitter
```

Make sure `~/.local/bin` is in your `PATH`.

## Installation

```bash
# back up an existing config first
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

git clone git@github.com:kamilszwaradzki/nvim-config.git ~/.config/nvim
nvim
```

On first start lazy.nvim installs the plugins and nvim-treesitter compiles the parsers. Restart Neovim afterwards.

Verify:

```vim
:checkhealth vim.lsp
:checkhealth nvim-treesitter
:checkhealth fzf_lua
```

## Structure

```
~/.config/nvim
├── init.lua                  # load order
├── lazy-lock.json            # pinned plugin versions
└── lua
    ├── config
    │   ├── options.lua       # editor options
    │   ├── keymaps.lua       # general, LSP and pytest keymaps
    │   ├── lazy.lua          # lazy.nvim bootstrap
    │   ├── pytest.lua        # pytest runner
    │   ├── projects.lua      # project switcher
    │   └── bookmarks.lua     # bookmarks with descriptions
    └── plugins
        ├── lsp.lua           # BasedPyright + Ruff
        ├── treesitter.lua    # parsers, highlighting, folding
        ├── dap.lua           # debugger (file, pytest, Django, FastAPI)
        └── fzf.lua           # fuzzy finder
```

## Keymaps

Leader key: `Space`.

### General

| Keys | Action |
|---|---|
| `<leader>w` | save |
| `<leader>q` | quit |
| `<Esc>` | clear search highlight |
| `Ctrl-h/j/k/l` | move between windows |
| `J` / `K` (visual) | move selected lines down / up |

### LSP

| Keys | Action |
|---|---|
| `gd` | go to definition |
| `grr` | references |
| `gri` | implementation |
| `grn` / `<leader>rn` | rename |
| `gra` / `<leader>ca` | code action |
| `K` | hover documentation |
| `gO` | document symbols |
| `[d` / `]d` | previous / next diagnostic |
| `<leader>e` | diagnostic under cursor |
| `<leader>f` | format with Ruff |
| `Ctrl-Space` (insert) | trigger completion |
| `Ctrl-s` (insert) | signature help |

`grr`, `gri`, `grn`, `gra`, `gO`, `K`, `[d`, `]d` and `Ctrl-s` are Neovim defaults.

### Folding

| Keys | Action |
|---|---|
| `zc` / `zo` | close / open fold |
| `zM` / `zR` | close / open all folds |

### Debugging

| Keys | Action |
|---|---|
| `<leader>db` | toggle breakpoint |
| `<leader>dB` | conditional breakpoint |
| `<leader>dc` | start / continue |
| `<leader>dn` | step over |
| `<leader>di` | step into |
| `<leader>do` | step out |
| `<leader>dr` | toggle REPL |
| `<leader>dh` | value under cursor |
| `<leader>ds` | local variables |
| `<leader>dq` | terminate |
| `<leader>dt` | debug nearest test |
| `<leader>dT` | debug test class |

Launch configurations: current file, Django (`manage.py runserver --noreload`), FastAPI (`uvicorn app.main:app`; adjust the module path in `lua/plugins/dap.lua`).

### Tests (pytest)

| Keys | Action |
|---|---|
| `<leader>tn` | nearest test |
| `<leader>tf` | current file |
| `<leader>ta` | all tests |
| `<leader>tl` | repeat last run |

Results open in a terminal split at the bottom; press `q` there to close it. Uses `.venv/bin/pytest` from the project if present.

### Search

| Keys | Action |
|---|---|
| `<leader>ff` | files |
| `<leader>fg` | live grep |
| `<leader>fw` | grep word under cursor |
| `<leader>fb` | buffers |
| `<leader>fo` | recent files |
| `<leader>fr` | resume last search |
| `<leader>fs` / `<leader>fS` | symbols in file / workspace |
| `<leader>fd` / `<leader>fD` | diagnostics in file / workspace |
| `<leader>fh` | help tags |
| `<leader>fk` | keymaps |

`.venv`, `__pycache__`, `node_modules` and `.git` are excluded from file search and grep.

### Projects

| Keys | Action |
|---|---|
| `<leader>pa` | add current working directory to the project list |
| `<leader>pp` | switch project |
| `Ctrl-x` (in the picker) | remove project from the list (the directory is not touched) |

Projects can live anywhere on disk. Switching saves all buffers, closes the previous project's buffers, **stops its LSP servers** (to free RAM), changes the working directory and opens the file picker.

The list is stored in `~/.local/share/nvim/projects.json`, outside this repo, so private paths never end up on GitHub.

### Bookmarks

| Keys | Action |
|---|---|
| `<leader>ba` | add bookmark with a description (same line again: edit the description) |
| `<leader>bd` | delete bookmark on the current line |
| `<leader>bl` | list bookmarks of the current project (with preview) |

Bookmarked lines are marked with `»` in the sign column. Bookmarks follow the code when lines are added or removed above them, and the new positions are saved on `:w`. Changes made outside Neovim (`git checkout`, external tools) do not move them.

Each project (working directory) has its own list in `~/.local/share/nvim/bookmarks/`.

## Notes

- **Position encoding.** BasedPyright only supports UTF-16, Ruff prefers UTF-8. Mixed encodings in one buffer trigger a warning in `:checkhealth vim.lsp`, so Ruff is forced to UTF-16 in `lua/plugins/lsp.lua`.
- **Project root.** Start Neovim from the project root (where `pyproject.toml` or `.git` lives). LSP root detection, the debugger's `${workspaceFolder}`, the pytest runner, the project list and bookmarks all depend on it.
- **Project venv.** Debugger and test runner pick up `.venv` in the project directory automatically.
- **Memory.** BasedPyright runs with `diagnosticMode = "openFilesOnly"` to keep RAM usage low on larger projects.

## Project setup for better type checking

Install type stubs into the project's venv:

```bash
uv add --dev django-stubs djangorestframework-stubs   # Django / DRF
```

SQLAlchemy 2.x and Pydantic v2 ship their own type hints and need no extra stubs.
