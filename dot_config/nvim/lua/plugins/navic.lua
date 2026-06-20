return {
  'smiteshp/nvim-navic',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    lsp = {
      auto_attach = true,
      preference = { 'html', 'templ' },
    },
    separator = ' 󰁔 ',
  },
}
