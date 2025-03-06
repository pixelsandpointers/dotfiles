local map = require('utils').map

map('n', '<localleader>s', ':VimtexCompile<CR>', { buffer = true, desc = 'Vimtex Start Compiler' })
map('n', '<localleader>C', ':VimtexClean<CR>', { buffer = true, desc = 'Vimtex Clean' })
map('n', '<localleader>c', ':!compile-latex<CR>', { buffer = true, desc = 'Compile Latex Document' })
map('n', '<localleader>o', ':VimtexTocToggle<CR>', { buffer = true, desc = 'Vimtex Open TOC' })
