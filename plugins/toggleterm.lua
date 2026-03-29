local opencode_term

---@type LazySpec
return {
  "akinsho/toggleterm.nvim",
  opts = {
    direction = "float",
    float_opts = {
      border = "none",
      width = function() return vim.o.columns end,
      height = function() return math.floor(vim.o.lines / 2) end,
      row = function() return math.ceil(vim.o.lines / 2) - 1 end,
      col = 0,
    },
  },
  keys = {
    {
      "<F8>",
      function()
        local Terminal = require("toggleterm.terminal").Terminal
        if not opencode_term then
          opencode_term = Terminal:new {
            cmd = "bash -ic 'oc'",
            count = 99,
            direction = "float",
            float_opts = {
              border = "none",
              width = vim.o.columns,
              height = vim.o.lines - 1,
              row = 0,
              col = 0,
            },
            on_open = function() vim.cmd "startinsert!" end,
          }
        end
        opencode_term:toggle()
      end,
      desc = "OpenCode",
      mode = { "n", "t" },
    },
  },
}
