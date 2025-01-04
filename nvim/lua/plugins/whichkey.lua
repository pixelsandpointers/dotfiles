return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy', -- Sets the loading event to 'VimEnter'
    opts = {
      preset = 'helix',
      spec = {
        -- Document existing key chains
        { '<leader>c', name = 'Code' },
        { '<leader>f', group = 'Find' },
        { '<localleader>', group = 'Mode' },
      },
    },
  },
}
