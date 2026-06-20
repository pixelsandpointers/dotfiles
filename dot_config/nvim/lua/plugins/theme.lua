return {
  {
    'kdheepak/monochrome.nvim',
    -- If I want to feel classy.
  },
  {
    'scottmckendry/cyberdream.nvim',
    lazy = false,
    priority = 1000,
    ---@type cyberdream.Config
    opts = {
      variant = 'auto',
      transparent = true,
      italic_comments = true,
      hide_fillchars = true,
      terminal_colors = false,
      cache = true,
      borderless_pickers = true,
      extensions = {
        blinkcmp = true,
      },
      overrides = function(c)
        return {
          CursorLine = { bg = c.bg },
          CursorLineNr = { fg = c.magenta },
        }
      end,
    },
    config = function(_, opts)
      require('cyberdream').setup(opts)
      vim.cmd.colorscheme 'cyberdream'
    end,
  },
}
