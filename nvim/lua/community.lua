-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- colorschemes
  { import = "astrocommunity.colorscheme.catppuccin" },
  -- language packs
  { import = "astrocommunity.pack.rust" },
  -- navigation
  { import = "astrocommunity.motion.harpoon" },
  { import = "astrocommunity.motion.flash-nvim" },
  -- AI completion
  { import = "astrocommunity.completion.copilot-vim-cmp" },
  { import = "astrocommunity.completion.blink-cmp" },
  { import = "astrocommunity.completion.copilot-vim" },
  { import = "astrocommunity.completion.copilot-lua-cmp" },
  { import = "astrocommunity.completion.copilot-lua" },
}
