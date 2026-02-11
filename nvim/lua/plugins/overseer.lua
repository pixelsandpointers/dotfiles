-- https://github.com/stevearc/overseer.nvim/blob/master/doc/guides.md#template-providers
return {
  'stevearc/overseer.nvim',
  opts = {},
  keys = {
    { '<leader>rb', '<cmd>OverseerBuild<CR>', 'Overseer: Build Command' },
    { '<leader>rc', '<cmd>OverseerRunCmd<CR>', 'Overseer: Run Shell Command' },
    { '<leader>rr', '<cmd>OverseerRun<CR>', 'Overseer: Run' },
    { '<leader>rl', '<cmd>OverseerLoadBundle<CR>', 'Overseer: Load Bundle' },
    { '<leader>rs', '<cmd>OverseerSaveBundle<CR>', 'Overseer: Save Bundle' },
    { '<leader>rd', '<cmd>OverseerDeleteBundle<CR>', 'Overseer: Delete Bundle' },
    { '<leader>rt', '<cmd>OverseerToggle bottom<CR>', 'Overseer: Open' },
  },
}
