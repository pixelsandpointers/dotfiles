-- slang.nvim - local plugin
return {
  dir = vim.fn.stdpath 'config' .. '/dev/slang.nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'stevearc/conform.nvim',
  },
  opts = {
    auto_format = true,
    inlay_hints = true,
  },
}
