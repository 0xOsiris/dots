-- Neo-tree configuration - show hidden files by default

---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
    filesystem = {
      hijack_netrw_behavior = "disabled",
      filtered_items = {
        visible = true, -- show hidden files by default
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
