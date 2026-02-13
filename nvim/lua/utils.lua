local M = {}
function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
function M.in_mathzone()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  -- Check if cursor is between $ $ (inline math)
  local before = line:sub(1, col)
  local after = line:sub(col + 1)

  -- Count $ signs before and after cursor
  local _, count_before = before:gsub('%$', '')
  local _, count_after = after:gsub('%$', '')

  -- If odd number of $ before and after, we're in math
  return (count_before % 2 == 1) and (count_after % 2 == 1)
end

function M.not_mathzone()
  return not M.in_mathzone()
end

return M
