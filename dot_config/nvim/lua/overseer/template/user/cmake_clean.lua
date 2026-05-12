return {
  name = 'cmake clean',
  builder = function()
    return {
      cmd = { 'rm' },
      args = { '-rf', 'build' },
      components = { 'default' },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.isdirectory('build') == 1
    end,
  },
}
