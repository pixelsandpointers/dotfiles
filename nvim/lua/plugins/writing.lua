return {
  {
    'lervag/vimtex',
    lazy = false, -- we don't want to lazy load VimTeX
    -- init = function()
    --   vim.g.vimtex_view_method = 'zathura'
    -- end,
    config = function()
      -- INFO: requires vim.g. attributes, i.e.
      --     Value      Documentation              Configuration ~
      -- `latexmk`    |vimtex-compiler-latexmk|    |g:vimtex_compiler_latexmk|
      -- `latexrun`   |vimtex-compiler-latexrun|   |g:vimtex_compiler_latexrun|
      -- `tectonic`   |vimtex-compiler-tectonic|   |g:vimtex_compiler_tectonic|
      -- `arara`      |vimtex-compiler-arara|      |g:vimtex_compiler_arara|
      -- `generic`    |vimtex-compiler-generic|    |g:vimtex_compiler_generic|

      -- vim.g.vimtex_compiler_latexmk
    end,
  },
  {
    'folke/twilight.nvim',
  },

  {
    'folke/zen-mode.nvim',
    config = function()
      vim.keymap.set('n', '<leader>z', function()
        require('zen-mode').toggle()
      end, { noremap = true })
    end,
  },

  {
    'preservim/vim-pencil',
  },
  {
    'tihawk/mdwa.nvim',
    version = '*',
  },
}
