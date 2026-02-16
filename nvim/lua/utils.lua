local M = {}
function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
function M.in_mathzone()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line_num = cursor[1]
  local col = cursor[2]
  local current_line = vim.api.nvim_get_current_line()

  -- Get all lines in the buffer for multi-line math detection
  local total_lines = vim.api.nvim_buf_line_count(0)

  -- Check for multi-line display math ($$\n...\n$$)
  -- Count $$ delimiters before current position
  local display_count_before = 0
  for i = 1, current_line_num - 1 do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    local _, count = line:gsub('%$%$', '')
    display_count_before = display_count_before + count
  end
  -- Add $$ from current line before cursor
  local before_cursor = current_line:sub(1, col)
  local _, count = before_cursor:gsub('%$%$', '')
  display_count_before = display_count_before + count

  -- Count $$ delimiters after current position
  local display_count_after = 0
  local after_cursor = current_line:sub(col + 1)
  local _, count_after = after_cursor:gsub('%$%$', '')
  display_count_after = display_count_after + count_after
  for i = current_line_num + 1, total_lines do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    local _, count = line:gsub('%$%$', '')
    display_count_after = display_count_after + count
  end

  -- Check if in display math (odd number of $$ before and after)
  local in_display_math = (display_count_before % 2 == 1) and (display_count_after % 2 == 1)

  -- Check for inline math on current line only ($...$)
  -- Remove all $$ first to avoid confusion
  local before_no_display = before_cursor:gsub('%$%$', '')
  local after_no_display = after_cursor:gsub('%$%$', '')
  local _, single_before = before_no_display:gsub('%$', '')
  local _, single_after = after_no_display:gsub('%$', '')
  local in_inline_math = (single_before % 2 == 1) and (single_after % 2 == 1)

  return in_display_math or in_inline_math
end

function M.not_mathzone()
  return not M.in_mathzone()
end

return M
