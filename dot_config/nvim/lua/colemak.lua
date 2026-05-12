-- Colemak-DH remaps for when a ZSA keyboard (Voyager/Moonlander) is connected.
-- Swaps hjkl navigation to mnei (same physical positions on Colemak-DH),
-- and remaps the displaced keys so nothing is lost.

local M = {}

--- Check if a ZSA keyboard is connected (vendor ID 0x3297)
function M.zsa_connected()
  local result
  if vim.fn.has('mac') == 1 then
    result = vim.fn.system('system_profiler SPUSBDataType 2>/dev/null | grep -i "ZSA"')
  else
    result = vim.fn.system('lsusb 2>/dev/null | grep -i 3297')
  end
  return vim.v.shell_error == 0 and result ~= ''
end

function M.setup()
  if not M.zsa_connected() then
    return
  end

  local modes = { 'n', 'x', 'o' }

  -- Navigation: mnei → hjkl
  vim.keymap.set(modes, 'm', 'h', { noremap = true, desc = 'Left' })
  vim.keymap.set(modes, 'n', 'j', { noremap = true, desc = 'Down' })
  vim.keymap.set(modes, 'e', 'k', { noremap = true, desc = 'Up' })
  vim.keymap.set(modes, 'i', 'l', { noremap = true, desc = 'Right' })

  -- Displaced originals: hjkl → mnei functions
  vim.keymap.set(modes, 'h', 'm', { noremap = true, desc = 'Set mark' })
  vim.keymap.set(modes, 'j', 'e', { noremap = true, desc = 'End of word' })
  vim.keymap.set(modes, 'k', 'n', { noremap = true, desc = 'Next search match' })
  vim.keymap.set(modes, 'l', 'i', { noremap = true, desc = 'Insert' })

  -- Uppercase variants
  vim.keymap.set(modes, 'M', 'H', { noremap = true, desc = 'Top of screen' })
  vim.keymap.set(modes, 'N', 'J', { noremap = true, desc = 'Join lines' })
  vim.keymap.set(modes, 'E', 'K', { noremap = true, desc = 'Keyword lookup' })
  vim.keymap.set(modes, 'I', 'L', { noremap = true, desc = 'Bottom of screen' })

  vim.keymap.set(modes, 'H', 'M', { noremap = true, desc = 'Middle of screen' })
  vim.keymap.set(modes, 'J', 'E', { noremap = true, desc = 'End of WORD' })
  vim.keymap.set(modes, 'K', 'N', { noremap = true, desc = 'Previous search match' })
  vim.keymap.set(modes, 'L', 'I', { noremap = true, desc = 'Insert at beginning of line' })

  -- Arrow keys for window navigation (avoids C-m/C-i terminal conflicts)
  vim.keymap.set('n', '<Left>', '<C-w><C-h>', { noremap = true, desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<Down>', '<C-w><C-j>', { noremap = true, desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<Up>', '<C-w><C-k>', { noremap = true, desc = 'Move focus to the upper window' })
  vim.keymap.set('n', '<Right>', '<C-w><C-l>', { noremap = true, desc = 'Move focus to the right window' })

  -- Terminal mode window navigation
  vim.keymap.set('t', '<Left>', '<C-\\><C-n><C-w>h', { noremap = true, desc = 'Move focus to the left window' })
  vim.keymap.set('t', '<Down>', '<C-\\><C-n><C-w>j', { noremap = true, desc = 'Move focus to the lower window' })
  vim.keymap.set('t', '<Up>', '<C-\\><C-n><C-w>k', { noremap = true, desc = 'Move focus to the upper window' })
  vim.keymap.set('t', '<Right>', '<C-\\><C-n><C-w>l', { noremap = true, desc = 'Move focus to the right window' })
end

return M
