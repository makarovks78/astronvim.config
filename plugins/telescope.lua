return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    local actions = require("telescope.actions")

    -- Настройка сортировки и маппингов для пикера буферов
    opts.pickers = {
      buffers = {
        sort_mru = true,            -- Сортировка по времени последнего использования
        sort_lastused = true,
        mappings = {
          i = {
            ["<C-d>"] = actions.delete_buffer, -- Удалить буфер в insert mode
          },
          n = {
            ["x"] = actions.delete_buffer,     -- Удалить буфер кнопкой 'd'
          },
        },
      },
    }
  end,
}
