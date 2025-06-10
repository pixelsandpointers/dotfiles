return {
  {
    'folke/twilight.nvim',
  },

  {
    'folke/zen-mode.nvim',
    config = function()
      vim.keymap.set('n', '<leader>z', function()
        require('zen-mode').toggle()
      end, { noremap = true })
    end,
  },

  {
    'preservim/vim-pencil',
  },
}
