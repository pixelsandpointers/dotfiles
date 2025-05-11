-- lua/plugins/rose-pine.lua
return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    config = function()
      vim.cmd 'colorscheme rose-pine'
    end,
  },
  {
    'rebelot/kanagawa.nvim',
    -- config = function()
    --   vim.cmd 'colorscheme kanagawa'
    -- end,
  },
  { 'akinsho/horizon.nvim', version = '*' },
  { 'EdenEast/nightfox.nvim' }, -- lazy
}
