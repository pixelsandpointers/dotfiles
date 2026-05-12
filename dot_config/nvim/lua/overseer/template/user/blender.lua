return {
  name = 'blender run',
  builder = function()
    local path = '../build_darwin_debug/bin/Blender.app/Contents/MacOS/Blender'
    return {
      cmd = { path },
      components = { { 'on_output_quickfix', open = true }, 'default' },
    }
  end,
}
