local util          = require 'arasaka.util'
local theme         = require 'arasaka.highlight'

vim.o.background    = 'dark'
vim.g.colors_name   = 'arasaka'

util.load(theme)