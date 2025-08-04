return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'saghen/blink.cmp',
    -- Useful status updates for LSP.
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', opts = {} },
  },
  opts = {
    -- TODO: https://neovim.io/doc/user/lsp.html#lsp-config
    -- Change this at some point to the native API
    servers = {
      -- cmake_language_server = {},
      texlab = {},
      tailwindcss = {},
      clangd = {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--offset-encoding=utf-8',
        },
        root_markers = { '.git', '.clangd', 'compile_commands.json' },
        filetypes = { 'c', 'cpp', 'cxx', 'hxx', 'cc', 'hh', 'hpp' },
      },
      astro = {},
      pyright = {},
      debugpy = {},
      ruff = {},
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              -- Tells lua_ls where to find all the Lua files that you have loaded
              -- for your neovim configuration.
              library = {
                '${3rd}/luv/library',
                unpack(vim.api.nvim_get_runtime_file('', true)),
              },
              -- If lua_ls is really slow on your computer, you can try this instead:
              -- library = { vim.env.VIMRUNTIME },
            },
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
          },
        },
      },
    },
  },
  config = function(_, opts)
    -- Load this on LSP attach (otherwise we don't need it)
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    local native_capabilities = vim.lsp.protocol.make_client_capabilities()
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    local lspconfig = require 'lspconfig'
    for server, config in pairs(opts.servers) do
      config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
      lspconfig[server].setup(config)
    end

    print(vim.tbl_keys(opts.servers))
    local ensure_installed = vim.tbl_keys(opts.servers)
    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format lua code
      'codelldb', -- debugger
    })
    require('mason').setup()
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- manual LSP config (cannot be installed by Mason)
    lspconfig['slangd'].setup { capabilities = capabilities }
    -- local sourcekit_capabilities = vim.tbl_deep_extend('force', native_capabilities, {
    --   filetypes = 'swift',
    --   workspace = {
    --     didChangeWatchedFiles = {
    --       dynamicRegistration = true,
    --     },
    --   },
    -- })
    -- lspconfig['sourcekit'].setup { capabilities = sourcekit_capabilities }
  end,
}
