-- lua/plugins/rose-pine.lua
return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
  },
  {
    'rebelot/kanagawa.nvim',
    -- config = function()
    --   vim.cmd 'colorscheme kanagawa'
    -- end,
  },
  { 'akinsho/horizon.nvim', version = '*' },
  {
    'EdenEast/nightfox.nvim',
    config = function()
      vim.cmd 'colorscheme terafox'
    end,
  }, -- lazy
}
