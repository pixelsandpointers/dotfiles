return {
  name = 'cmake configure',
  builder = function()
    return {
      cmd = { 'cmake' },
      args = {
        '-S', '.', '-B', 'build/Debug',
        '-DCMAKE_BUILD_TYPE=Debug',
        '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON',
      },
      components = { { 'on_output_quickfix', open = true }, 'default' },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.filereadable('CMakeLists.txt') == 1
    end,
  },
}
