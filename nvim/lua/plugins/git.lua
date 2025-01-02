return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed.
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { desc = 'Git: ' .. desc })
    end

    -- keymap
    map('<leader>g', require('neogit').open, 'Setup')
  end,
}
