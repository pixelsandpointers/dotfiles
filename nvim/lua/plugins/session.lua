return {
  'echasnovski/mini.sessions',
  version = false,
  config = function()
    require('mini.sessions').setup {}
    local map = require('utils').map
    map('n', '<leader>qs', '<cmd>mksession<CR>', { noremap = true, desc = 'Save session' })
  end,
}
