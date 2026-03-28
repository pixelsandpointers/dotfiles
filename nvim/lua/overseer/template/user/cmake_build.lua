return {
  name = 'cmake build',
  builder = function()
    local build_dir = 'build/Debug'
    if vim.fn.isdirectory('build/Release') == 1 and vim.fn.isdirectory('build/Debug') == 0 then
      build_dir = 'build/Release'
    end
    return {
      cmd = { 'cmake' },
      args = { '--build', build_dir, '-j' },
      components = { { 'on_output_quickfix', open = true }, 'default' },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.isdirectory('build/Debug') == 1 or vim.fn.isdirectory('build/Release') == 1
    end,
  },
}
