return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup {
        preset = 'modern',
      }

      local wk = require 'which-key'

      wk.add {
        -- Document existing key chains
        { '<leader>c', name = 'Code', _ = 'which_key_ignore' },
        { '<leader>f', group = 'Find', _ = 'which_key_ignore' },
        { '<localleader>', group = 'Mode', _ = 'which_key_ignore' },
      }
    end,
  },
}
