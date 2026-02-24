-- OpenAI Codex CLI integration

---@type LazySpec
return {
  "akinsho/toggleterm.nvim",
  keys = {
    {
      "<Leader>cx",
      function()
        local Terminal = require("toggleterm.terminal").Terminal
        local codex = Terminal:new({
          cmd = "codex",
          dir = vim.fn.getcwd(),
          direction = "float",
          float_opts = {
            border = "curved",
            width = math.floor(vim.o.columns * 0.9),
            height = math.floor(vim.o.lines * 0.9),
          },
          on_open = function(term)
            vim.cmd("startinsert!")
            vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
          end,
          close_on_exit = true,
        })
        codex:toggle()
      end,
      desc = "Open Codex CLI",
    },
  },
}
