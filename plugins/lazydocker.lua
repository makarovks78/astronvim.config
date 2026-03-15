return {
  "crnvl96/lazydocker.nvim",
  lazy = true,
  keys = {
    {
      "<leader>D",
      function()
        require('lazydocker').toggle({ engine = 'docker' })
      end,
      desc = "LazyDocker"
    }
  }
}
