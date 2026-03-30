require("neo-tree.sources.manager")
require("layout.sidebars")

vim.keymap.set("n", "J", "5j", { noremap = true })
vim.keymap.set("n", "K", "5k", { noremap = true })

vim.keymap.set("v", "J", "5j", { noremap = true })
vim.keymap.set("v", "K", "5k", { noremap = true })

vim.keymap.set("v", "y", "ygv<Esc>", { noremap = true })

vim.keymap.set("n", "oo", "o<Esc>k", {noremap = true})

vim.keymap.set("n", "<leader>L", "<cmd>LazySql<CR>", { desc = "LazySql", noremap = true, silent = true })
vim.keymap.set("n", "<F12>", "<cmd>Telescope buffers<CR>", { desc = "Buffers", noremap = true, silent = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "mysql", "sql", "dbui", "dbout" },
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true, noremap = true }

    -- ===== EXECUTION =====
    vim.keymap.set("n", "<Leader>a", "", opts)

    vim.keymap.set({ "n", "v" }, "<Leader>aS", "<Plug>(DBUI_ExecuteQuery)", opts)
    vim.keymap.set("n", "<Leader>aE", "<Plug>(DBUI_ExplainQuery)", opts)
    vim.keymap.set("n", "<Leader>aB", "<Plug>(DBUI_BindParameters)", opts)

    -- ===== RESULTS =====
    vim.keymap.set("n", "<Leader>aR", "<Plug>(DBUI_ToggleResult)", opts)

    -- ===== FILES =====
    vim.keymap.set("n", "<Leader>aW", "<Plug>(DBUI_SaveQuery)", opts)

    -- ===== UI / SPLITS =====
    vim.keymap.set("n", "<Leader>aV", "<Plug>(DBUI_SelectLineVsplit)", opts)
    vim.keymap.set("n", "<Leader>aH", "<Plug>(DBUI_SelectLineHsplit)", opts)
  end,
})

vim.o.title = true
vim.o.titlestring = "Neovim123"

vim.opt.guicursor = {
  "n-v-c:block",        -- нормальный, визуальный, командный режим → блок
  "i:ver60-Cursor",     -- insert mode → вертикальная черта, 60% ширины
  "r:hor20-Cursor",     -- replace → горизонтальная 20%
  "o:hor50-Cursor",     -- оператор → горизонтальная 50%
}

-- Настройка highlight для курсора
vim.cmd([[
  hi Cursor guifg=NONE guibg=#FFD700
  hi lCursor guifg=NONE guibg=#FF4500
]])

vim.api.nvim_create_autocmd("SessionLoadPost", {
  callback = function()
    local ok, manager = pcall(require, "neo-tree.sources.manager")
    if not ok then return end

    local state = manager.get_state("filesystem")
    if not state or not state.path then return end

    vim.cmd("cd " .. state.path)

    vim.cmd("LspStop")
    vim.defer_fn(function()
      vim.cmd("LspStart")
    end, 100)
  end,
})
