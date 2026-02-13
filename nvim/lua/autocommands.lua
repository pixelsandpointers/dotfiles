-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Slang filetype detection
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.slang', '*.slangh' },
  callback = function()
    vim.bo.filetype = 'slang'
  end,
})

-- Auto-activate uv virtual environment
local function activate_venv()
  local venv_path = vim.fn.getcwd() .. '/.venv'
  if vim.fn.isdirectory(venv_path) == 1 then
    local python_path = venv_path .. '/bin/python'
    if vim.fn.filereadable(python_path) == 1 then
      vim.g.python3_host_prog = python_path
      -- Also set VIRTUAL_ENV for tools that check it
      vim.env.VIRTUAL_ENV = venv_path
      vim.env.PATH = venv_path .. '/bin:' .. vim.env.PATH
    end
  end
end

vim.api.nvim_create_autocmd({ 'VimEnter', 'DirChanged' }, {
  desc = 'Automatically activate .venv when present',
  group = vim.api.nvim_create_augroup('auto-activate-venv', { clear = true }),
  callback = activate_venv,
})
