local map = require('utils').map
local clangx = require 'clangd_extensions'

map('n', '<localleader>h', '<Cmd>ClangdSwitchSourceHeader<CR>', { desc = 'Switch to header' })
map('n', '<localleader>bd', ':!cmake_deb -S . -B build && cmake --build build<CR>', { buffer = true, desc = 'CMake: Compile Debug' })
map('n', '<localleader>br', ':!cmake_rel -S . -B build && cmake --build build<CR>', { buffer = true, desc = 'CMake: Compile Release' })
map('n', '<localleader>bb', ':!cmake --build build -j16', { desc = 'CMake: Build' })
map('n', '<localleader>r', function()
  local prog = vim.fn.input('Path to executable: ', './build/a.out')
  vim.api.nvim_command(':!' .. prog)
end, { buffer = false, desc = 'Run executable' })
