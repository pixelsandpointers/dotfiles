return {
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      local gitsigns = require 'gitsigns'
      vim.keymap.set('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'Git: Reset region' })
      vim.keymap.set('n', '<leader>gb', gitsigns.blame, { desc = 'Git: Blame' })
      gitsigns.setup()
    end,
  },
  {
    'sindrets/diffview.nvim',
    config = function()
      local diff = require 'diffview'
      vim.keymap.set('n', '<leader>gd', ':OpenDiffview ', { desc = 'Git: Open Diffview' })
      vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', { desc = 'Git: Open file history' })
      diff.setup()
    end,
  },
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration

      -- Only one of these is needed.
      'folke/snacks.nvim',
    },
    config = function()
      require('neogit').setup {
        mappings = {
          popup = {
            ['P'] = 'PullPopup',
            ['p'] = 'PushPopup',
          },
        },
      }
    end,
    keys = {
      {
        '<leader>gg',
        function()
          require('neogit').open()
        end,
        desc = 'Git: Status',
      },
    },
  },
  {
    'rbong/vim-flog',
    lazy = true,
    cmd = { 'Flog', 'Flogsplit', 'Floggit' },
    dependencies = {
      'tpope/vim-fugitive',
    },
    keys = {
      { '<leader>gs', '<cmd>Flog<CR>', desc = 'Git: Graph' },
    },
  },
}
