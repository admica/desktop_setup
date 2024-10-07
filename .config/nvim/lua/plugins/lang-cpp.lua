-- ~/.config/nvim/lua/plugins/lang-cpp.lua

return {
  -- Enhanced C++ syntax highlighting
  { "bfrg/vim-cpp-modern", ft = { "c", "cpp" } },

  -- Symbol outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    config = true,
  },

  -- clangd extensions for better C++ support
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp" },
    config = true,
  },
}
