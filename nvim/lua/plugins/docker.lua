-- Lazydocker integration for viewing containers and logs

---@type LazySpec
return {
  "crnvl96/lazydocker.nvim",
  event = "VeryLazy",
  dependencies = { "akinsho/toggleterm.nvim" },
  opts = {},
  keys = {
    {
      "<Leader>ld",
      function() require("lazydocker").toggle() end,
      desc = "Toggle Lazydocker",
    },
  },
}
