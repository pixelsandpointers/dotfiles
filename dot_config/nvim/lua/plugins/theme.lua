return {
  {
    'kdheepak/monochrome.nvim',
    -- If I want to feel classy.
    config = function()
      local transparent_groups = {
        'Normal',
        'NormalNC',
        'NormalFloat',
        'SignColumn',
        'EndOfBuffer',
        'LineNr',
        'Folded',
        'FoldColumn',
        'MsgArea',
        'VertSplit',
        'WinSeparator',
        'TabLine',
        'TabLineFill',
        'TelescopeNormal',
        'TelescopeBorder',
        'NvimTreeNormal',
        'NvimTreeNormalNC',
      }
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = 'monochrome',
        callback = function()
          for _, group in ipairs(transparent_groups) do
            local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
            hl.bg = nil
            hl.ctermbg = nil
            vim.api.nvim_set_hl(0, group, hl)
          end

          -- monochrome.nvim never defines these, so they fall back to
          -- plain fg after `hi clear` and look "grayed out" in neo-tree.
          local colors = require 'monochrome.colors'
          local git_groups = {
            NeoTreeGitAdded = colors.faded_green,
            NeoTreeGitModified = colors.faded_yellow,
            NeoTreeGitDeleted = colors.faded_red,
            NeoTreeGitRenamed = colors.faded_blue,
            NeoTreeGitUntracked = colors.faded_orange,
            NeoTreeGitIgnored = colors.gray4,
            NeoTreeGitStaged = colors.faded_green,
            NeoTreeGitUnstaged = colors.faded_yellow,
            NeoTreeGitConflict = colors.bright_red,
          }
          for group, fg in pairs(git_groups) do
            vim.api.nvim_set_hl(0, group, { fg = fg })
          end

          -- Dedicated groups for lua/statusline.lua, kept separate from real
          -- syntax/diff groups (Directory/Number/String/Keyword/Changed/Added/
          -- Removed) so we don't clobber actual code and diff highlighting.
          local statusline_groups = {
            StatuslineModeNormal = colors.faded_blue,
            StatuslineModeVisual = colors.faded_purple,
            StatuslineModeInsert = colors.faded_green,
            StatuslineModeCommand = colors.faded_yellow,
            StatuslineGitBranch = colors.faded_green,
            StatuslineGitAdded = colors.faded_green,
            StatuslineGitRemoved = colors.faded_red,
            DiagnosticError = colors.faded_red,
            DiagnosticWarn = colors.faded_yellow,
            DiagnosticInfo = colors.faded_blue,
            DiagnosticHint = colors.faded_aqua,
          }
          for group, fg in pairs(statusline_groups) do
            vim.api.nvim_set_hl(0, group, { fg = fg })
          end
        end,
      })
      vim.opt.fillchars:append {
        eob = ' ',
        fold = ' ',
        vert = ' ',
        horiz = ' ',
        horizup = ' ',
        horizdown = ' ',
        vertleft = ' ',
        vertright = ' ',
        verthoriz = ' ',
      }
      vim.cmd.colorscheme 'monochrome'
    end,
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
      -- require('cyberdream').setup(opts)
      -- vim.cmd.colorscheme 'cyberdream'
    end,
  },
}
