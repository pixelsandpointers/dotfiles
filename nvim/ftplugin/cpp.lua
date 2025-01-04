local map = require('utils').map

map('n', '<localleader>rc', ':!cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=1 && cmake --build build<CR>', { buffer = true, desc = 'CMake: Compile' })
map('n', '<localleader>rb', ':!cmake --build build -j16', { desc = 'Build' })
map('n', '<localleader>rr', function()
  local prog = vim.fn.input('Path to executable: ', './build/a.out')
  vim.api.nvim_command(':!' .. prog)
end, { buffer = false, desc = 'Run' })
