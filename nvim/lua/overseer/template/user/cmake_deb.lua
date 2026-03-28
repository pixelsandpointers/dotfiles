return {
  name = 'cmake debug (configure + build)',
  builder = function()
    return {
      cmd = { 'cmake' },
      args = {
        '-S', '.', '-B', 'build/Debug',
        '-DCMAKE_BUILD_TYPE=Debug',
        '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON',
      },
      components = {
        { 'on_output_quickfix', open = true },
        {
          'run_after',
          tasks = {
            { cmd = { 'cmake' }, args = { '--build', 'build/Debug', '-j' } },
          },
        },
        'default',
      },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.filereadable('CMakeLists.txt') == 1
    end,
  },
}
