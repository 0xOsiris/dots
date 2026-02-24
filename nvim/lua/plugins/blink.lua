-- Extend blink.cmp with command-line completion
return {
  "saghen/blink.cmp",
  opts = {
    cmdline = {
      enabled = true,
      keymap = { preset = "inherit" },
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },
  },
}
