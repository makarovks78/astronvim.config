local sidebars = require("layout.sidebars")

return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true }, -- Optional
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  keys = {
    { "<Leader>k",
      function()
        vim.cmd("DBUI")
      end,
      desc = "DB UI" },
  },
  init = function()
    vim.g.db_ui_win_position = "right"
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}
