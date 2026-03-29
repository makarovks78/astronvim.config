# Agent Guidelines for AstroNvim Configuration

Personal Neovim config based on [AstroNvim v5+](https://github.com/AstroNvim/AstroNvim)
using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager.

## Project Structure

The git repository root is `lua/` (inside `~/.config/nvim/`).
Config files outside this repo (at `~/.config/nvim/`) include `init.lua`,
`.stylua.toml`, `selene.toml`, `.luarc.json`, `.neoconf.json`, and `neovim.yml`.

```
lua/                          # Git repo root (~/.config/nvim/lua/)
  community.lua               # AstroCommunity imports (currently deactivated)
  lazy_setup.lua              # lazy.nvim setup: loads AstroNvim, community, plugins
  polish.lua                  # Post-setup customizations (keymaps, autocmds, UI tweaks)
  layout/
    sidebars.lua              # Sidebar auto-close utility module
  plugins/                    # One file per plugin (or logical group)
    astrocommunity.lua        # Community plugin imports (kanagawa colorscheme)
    astrolsp.lua              # LSP configuration
    astroui.lua               # UI theme and icons
    codecompanion.lua         # AI chat (Copilot adapter)
    copilot.lua               # GitHub Copilot suggestions
    dadbod-compl.lua          # Database completion source for blink.cmp
    dadbod-ui.lua             # Database UI
    dashboard-projects.lua    # Custom dashboard with project shortcuts
    lazydocker.lua            # Docker TUI
    lazygit.lua               # Git TUI
    lazysql.lua               # SQL TUI
    stay-centered.lua         # Keep cursor centered
    telescope.lua             # Fuzzy finder customization
    toggleterm.lua            # Floating terminal
    wich-key.lua              # Which-key group registration
    astrocore.lua             # (deactivated) Core mappings/options template
    mason.lua                 # (deactivated) Mason tool installer
    none-ls.lua               # (deactivated) Null-ls sources
    treesitter.lua            # (deactivated) Treesitter config
    user.lua                  # (deactivated) Example plugin overrides
```

## Build / Lint / Test Commands

There is no build system, CI/CD, or test framework. Validation is manual.

### Formatting (StyLua)

Config: `~/.config/nvim/.stylua.toml`

```bash
stylua lua/                         # Format all files
stylua --check lua/                 # Check formatting (dry-run)
stylua lua/plugins/copilot.lua      # Format a single file
```

### Linting (Selene)

Config: `~/.config/nvim/selene.toml`, types: `~/.config/nvim/neovim.yml`

```bash
selene .                            # Lint all Lua files from repo root
selene lua/layout/sidebars.lua      # Lint a single file
```

### Testing

No automated tests exist. Verify changes by launching `nvim` and confirming
plugins load without errors (`:checkhealth`, `:Lazy`).

## Code Style

### Formatting Rules (from .stylua.toml)

| Setting              | Value              |
|----------------------|--------------------|
| Indent               | 2 spaces           |
| Line width           | 120 characters     |
| Line endings         | Unix (LF)          |
| Quote style          | Double quotes preferred (`AutoPreferDouble`) |
| Call parentheses     | Omit for single-arg calls (`call_parentheses = "None"`) |
| Simple statements    | Collapse to one line (`collapse_simple_statement = "Always"`) |

### Naming Conventions

- **Variables, functions, methods**: `snake_case` (`local sidebar_win`, `function M.track_sidebar()`)
- **Private/internal fields**: underscore prefix (`M._sidebar_win`)
- **Boolean predicates**: `is_` prefix (`is_sidebar`, `is_main_buffer`)
- **File names**: `kebab-case` for plugin configs (`dadbod-ui.lua`, `stay-centered.lua`);
  plain lowercase for non-plugin modules (`sidebars.lua`, `polish.lua`)
- **Constants**: `UPPER_SNAKE_CASE`

### Module Patterns

**Plugin specs** (files in `plugins/`): return a table directly.

```lua
---@type LazySpec
return {
  "owner/plugin-name",
  opts = { ... },
}
```

**Utility modules** (files in `layout/` or similar): use `local M = {}` / `return M`.

```lua
local M = {}

local function private_helper() end   -- no M. prefix
function M.public_method() end        -- M. prefix

return M
```

**Imperative scripts** (`polish.lua`, `lazy_setup.lua`): top-level code, no return.

### Deactivating Files

Disabled template files use this guard at line 1:

```lua
if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
```

### Imports / Requires

- Prefer `require("module")` with **double quotes and parentheses**.
- For lazy-loaded plugin code, use **inline `require()` inside callbacks** rather
  than top-level imports. This ensures the module is loaded only when needed:

```lua
keys = {
  {
    "<Leader>D",
    function() require("lazydocker").toggle() end,
    desc = "Lazydocker",
  },
}
```

- For immediately-needed imports, use `local x = require("module")` at file top.
- For optional dependencies, wrap with `pcall`:

```lua
local ok, module = pcall(require, "optional.module")
if not ok then return end
```

### Type Annotations

Use LuaLS/EmmyLua `---@type` annotations for lazy.nvim spec typing:

```lua
---@type LazySpec
return { ... }
```

And for AstroNvim option tables:

```lua
---@type AstroLSPOpts
opts = { ... }
```

Inline casts use `--[[@as Type]]`. Suppress diagnostics with `---@diagnostic disable: rule-name`.
No `---@param` / `---@return` annotations are used in this codebase.

### Keymappings

In `polish.lua`, use `vim.keymap.set` with an options table:

```lua
-- Leader mappings include desc (for which-key discoverability)
vim.keymap.set("n", "<Leader>L", "<cmd>LazySql<CR>", { desc = "LazySql", noremap = true, silent = true })
-- Simple motion remaps omit desc
vim.keymap.set("n", "J", "5j", { noremap = true })
```

In plugin specs, use the `keys` field for lazy-loaded keymaps:

```lua
keys = { { "<Leader>gl", "<cmd>LazyGit<cr>", desc = "LazyGit" } }
```

### Autocmds

Always use `vim.api.nvim_create_autocmd` with a `callback` function (never string commands):

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "dbui" },
  callback = function(ev) ... end,
})
```

### Error Handling

Minimal. Use `pcall` in two scenarios:
1. Safe-require for optional modules: `local ok, m = pcall(require, "module")`
2. Wrapping Neovim API calls that may fail: `pcall(vim.api.nvim_win_close, win, true)`

Validate state before acting: `if not vim.api.nvim_buf_is_valid(buf) then return end`

### Vim Options and Variables

- `vim.o` for simple scalar options (`vim.o.titlestring = "Neovim"`)
- `vim.opt` for list/table options (`vim.opt.guicursor = { ... }`)
- `vim.g` for global variables (`vim.g.db_ui_use_nerd_fonts = 1`)

### Comments

- Single-line `--` comments (English or Russian).
- Section separators use dashed lines in utility modules:
  ```lua
  -------------------------------------------------
  -- SECTION NAME
  -------------------------------------------------
  ```
- No multi-line `--[[ ]]` comment blocks (only used for `--[[@as Type]]` casts).

## Editor Setup

1. **lua_ls**: `:LspInstall lua_ls` -- formatting disabled in `.luarc.json` (StyLua handles it)
2. **StyLua**: `cargo install stylua` or via package manager
3. **Selene**: `cargo install selene` or via package manager

## Selene Configuration

From `selene.toml` -- these rules are explicitly allowed (do not flag them):
- `global_usage` -- globals like `vim` are expected
- `if_same_then_else` -- allowed
- `incorrect_standard_library_use` -- allowed (Neovim extends stdlib)
- `mixed_table` -- allowed (lazy.nvim specs mix array and dict entries)
- `multiple_statements` -- allowed
