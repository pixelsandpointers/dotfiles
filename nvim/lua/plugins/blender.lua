return {
  {
    'b0o/blender.nvim',
    config = function()
      local blender = require 'blender'
      blender.setup {
        profiles = function()
          -- local env = {}
          -- local ok, lines = pcall(vim.fn.readfile, 'myproject.env')
          -- if not ok then
          --   -- Don't generate a profile if the file doesn't exist
          --   return
          -- end
          -- if ok and lines then
          --   -- Read a key=value pair from each line of the file, and add it to the env table
          --   for _, line in ipairs(lines) do
          --     local key, value = line:match '^([^#]*)=(.*)$'
          --     if key and value then
          --       env[key] = value
          --     end
          --   end
          -- end
          return {
            name = 'Default',
            cmd = '/Applications/Blender45.app/Contents/MacOS/Blender',
            -- env = env,
          }
        end,
      }
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'grapp-dev/nui-components.nvim',
      'mfussenegger/nvim-dap', -- Optional, for debugging with DAP
      'LiadOz/nvim-dap-repl-highlights', -- Optional, for syntax highlighting in the DAP REPL
    },
  },
}
