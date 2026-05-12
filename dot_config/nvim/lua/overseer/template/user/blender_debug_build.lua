return {
  name = 'blender debug build',
  builder = function()
    return {
      cmd = { 'make', 'debug', 'developer', 'ccache', 'ninja' },
      components = { { 'on_output_quickfix', open = true }, 'default' },
    }
  end,
  condition = {
    filetype = { 'cpp' },
  },
}
