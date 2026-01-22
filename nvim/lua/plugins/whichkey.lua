return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy', -- Sets the loading event to 'VimEnter'
    opts = {
      preset = 'helix',
      spec = {
        -- Document existing key chains
        { '<leader>a', name = 'Claude' },
        { '<leader>z', name = 'ZenMode' },
        { '<leader>c', name = 'Code' },
        { '<leader>d', name = 'Debug' },
        { '<leader>f', group = 'Find' },
        { '<leader>g', group = 'Git' },
        { '<leader>o', group = 'Task Runner' },
        { '<localleader>', group = 'Mode' },
      },
    },
  },
}
