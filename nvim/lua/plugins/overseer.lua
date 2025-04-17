return {
  'stevearc/overseer.nvim',
  opts = {},
  config = function()
    require('overseer').setup()
  end,
  keys = {
    { '<leader>ob', '<cmd>OverseerBuild<CR>', 'Overseer: Build Command' },
    { '<leader>oc', '<cmd>OverseerRunCmd<CR>', 'Overseer: Run Shell Command' },
    { '<leader>or', ':OverseerRun ', 'Overseer: Run' },
    { '<leader>ol', '<cmd>OverseerLoadBundle<CR>', 'Overseer: Load Bundle' },
    { '<leader>os', '<cmd>OverseerSaveBundle<CR>', 'Overseer: Save Bundle' },
    { '<leader>od', '<cmd>OverseerDeleteBundle<CR>', 'Overseer: Delete Bundle' },
    { '<leader>ot', '<cmd>OverseerToggle bottom<CR>', 'Overseer: Open' },
  },
}
