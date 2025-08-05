return {
  'stevearc/conform.nvim',
  optional = true,
  opts = {
    formatters_by_ft = {
      python = { 'ruff_format' },
    },
    format_on_save = {
      --timeout_ms = 500,
      lsp_format = 'fallback',
    },
  },
  config = function(_, opts)
    local conform = require 'conform'
    conform.setup(opts)

    -- Set up the autocommand after conform is loaded
    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = '*',
      callback = function(args)
        conform.format { bufnr = args.buf }
      end,
    })
  end,
}
