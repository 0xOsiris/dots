-- Claude Code CLI integration

---@type LazySpec
return {
  "akinsho/toggleterm.nvim",
  keys = {
    {
      "<Leader>cc",
      function()
        local Terminal = require("toggleterm.terminal").Terminal
        local claude = Terminal:new({
          cmd = "claude",
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
        claude:toggle()
      end,
      desc = "Open Claude Code",
    },
    {
      "<Leader>cr",
      function()
        local Terminal = require("toggleterm.terminal").Terminal
        local claude_resume = Terminal:new({
          cmd = "claude --resume",
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
        claude_resume:toggle()
      end,
      desc = "Resume Claude Code",
    },
  },
}
