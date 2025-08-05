return {
  {
    'p00f/clangd_extensions.nvim',
    opts = {
      inline_hints = true,
    },
    config = function()
      require('clangd_extensions').setup {
        ast = {
          -- These are unicode, should be available in any font
          role_icons = {
            type = '🄣',
            declaration = '🄓',
            expression = '🄔',
            statement = ';',
            specifier = '🄢',
            ['template argument'] = '🆃',
          },
          kind_icons = {
            Compound = '🄲',
            Recovery = '🅁',
            TranslationUnit = '🅄',
            PackExpansion = '🄿',
            TemplateTypeParm = '🅃',
            TemplateTemplateParm = '🅃',
            TemplateParamObject = '🅃',
          },
          --[[ These require codicons (https://github.com/microsoft/vscode-codicons)
            role_icons = {
                type = "",
                declaration = "",
                expression = "",
                specifier = "",
                statement = "",
                ["template argument"] = "",
            },

            kind_icons = {
                Compound = "",
                Recovery = "",
                TranslationUnit = "",
                PackExpansion = "",
                TemplateTypeParm = "",
                TemplateTemplateParm = "",
                TemplateParamObject = "",
            }, ]]

          highlights = {
            detail = 'Comment',
          },
        },
        memory_usage = {
          border = 'none',
        },
        symbol_info = {
          border = 'none',
        },
      }
    end,
  },
  { -- LSP Configuration & Plugins
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
        -- Ensure mason installs the server
        clangd = {
          keys = {
            { '<localleader>h', '<cmd>ClangdSwitchSourceHeader<cr>', desc = 'Switch Source/Header (C/C++)' },
          },
          root_markers = { '.git', '.clangd', 'compile_commands.json' },
          filetypes = { 'c', 'cpp', 'cxx', 'hxx', 'cc', 'hh', 'hpp' },
          root_dir = function(fname)
            return require('lspconfig.util').root_pattern(
              'Makefile',
              'configure.ac',
              'configure.in',
              'config.h.in',
              'meson.build',
              'meson_options.txt',
              'build.ninja'
            )(fname) or require('lspconfig.util').root_pattern('compile_commands.json', 'compile_flags.txt')(fname) or require('lspconfig.util').find_git_ancestor(
              fname
            )
          end,
          capabilities = {
            offsetEncoding = { 'utf-16' },
          },
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--offset-encoding=utf-8',
            '--header-insertion=iwyu',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
        astro = {},
        pyright = {},
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

          vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })
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
      -- Mason installs without setup required
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format lua code
        'ruff',
        'codelldb', -- debugger
        'nil',
        'nixpkgs-fmt',
      })
      require('mason').setup()
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- manual LSP config (cannot be installed by Mason)
      lspconfig['slangd'].setup { capabilities = capabilities }
      lspconfig['nil'].setup { capabilities = capabilities }
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
  },
}
