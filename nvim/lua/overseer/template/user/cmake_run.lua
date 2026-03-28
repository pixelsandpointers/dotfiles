local function find_executables()
  local result = vim.fn.systemlist(
    'find build -type f -executable -not -path "*/CMakeFiles/*" 2>/dev/null'
  )
  if vim.v.shell_error ~= 0 then
    return {}
  end
  return result
end

---@type overseer.TemplateFileProvider
return {
  condition = {
    callback = function()
      return vim.fn.filereadable('CMakeLists.txt') == 1
    end,
  },
  generator = function(_, cb)
    local templates = {}
    for _, exe in ipairs(find_executables()) do
      table.insert(templates, {
        name = 'cmake run: ' .. exe,
        params = {
          args = {
            desc = 'Arguments (space-separated)',
            type = 'string',
            default = '',
            optional = true,
          },
        },
        builder = function(params)
          local args = {}
          if params.args and params.args ~= '' then
            for arg in params.args:gmatch('%S+') do
              table.insert(args, arg)
            end
          end
          return {
            cmd = { exe },
            args = args,
            components = {
              { 'on_output_quickfix', open = false },
              { 'on_complete_notify', statuses = { 'SUCCESS', 'FAILURE' } },
              'default',
            },
          }
        end,
      })
    end
    cb(templates)
  end,
}
