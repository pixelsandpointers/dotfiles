return {
  {
    'p00f/clangd_extensions.nvim',
    opts = {
      inline_hints = true,
    },
    config = function()
      local clangdx = require 'clangd_extensions'
      clangdx.setup {
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
      -- Using native Neovim 0.11+ API
      servers = {
        texlab = {},
        tailwindcss = {},
        -- Ensure mason installs the server
        clangd = {
          keys = {
            { '<localleader>h', '<cmd>ClangdSwitchSourceHeader<cr>', desc = 'Switch Source/Header (C/C++)' },
          },
          root_markers = { '.git', '.clangd', 'compile_commands.json' },
          filetypes = { 'c', 'cpp', 'cxx', 'hxx', 'cc', 'hh', 'hpp' },
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local root = vim.fs.root(fname, {
              'Makefile',
              'configure.ac',
              'configure.in',
              'config.h.in',
              'meson.build',
              'meson_options.txt',
              'build.ninja',
              'compile_commands.json',
              'compile_flags.txt',
              '.git',
            })
            if root then
              on_dir(root)
            end
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

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Configure all servers using native vim.lsp.config
      for server, config in pairs(opts.servers) do
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        vim.lsp.config(server, config)
      end

      local ensure_installed = vim.tbl_keys(opts.servers)
      -- Mason installs without setup required
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format lua code
        'neocmake',
        'codelldb', -- debugger
        'nixpkgs-fmt',
      })

      require('mason').setup()
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- manual LSP config (cannot be installed by Mason)
      local vulkan_sdk = vim.env.VULKAN_SDK or '/home/ben/dev/vulkan-sdk/1.4.341.0/x86_64'

      -- Merge slangd-specific capabilities with base capabilities
      local slangd_capabilities = vim.tbl_deep_extend('force', capabilities, {
        offsetEncoding = { 'utf-8', 'utf-16' },
        textDocument = {
          semanticTokens = vim.NIL, -- Disable semantic tokens (causes errors with synthetic buffers)
        },
      })

      -- Function to fetch builtin module code from slangd
      local function get_builtin_module_code(module_name, callback)
        local cmd = { vulkan_sdk .. '/bin/slangd', '--print-builtin-module', module_name }
        vim.system(cmd, { text = true }, function(obj)
          if obj.code == 0 then
            callback(obj.stdout)
          else
            callback('// Error fetching module ' .. module_name .. '\n// ' .. (obj.stderr or ''))
          end
        end)
      end


      -- Pre-create buffers for slang-synth URIs using BufReadCmd autocmd
      vim.api.nvim_create_autocmd('BufReadCmd', {
        pattern = 'slang-synth://*',
        callback = function(ev)
          local uri = vim.api.nvim_buf_get_name(ev.buf)
          local module_name = uri:match('slang%-synth://([^/]+)')
          if module_name then
            local cmd = { vulkan_sdk .. '/bin/slangd', '--print-builtin-module', module_name }
            local obj = vim.system(cmd, { text = true }):wait()
            if obj.code == 0 and obj.stdout then
              vim.bo[ev.buf].buftype = 'nofile'
              vim.bo[ev.buf].modifiable = true
              local lines = vim.split(obj.stdout, '\n')
              vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, lines)
              vim.bo[ev.buf].modifiable = false
              vim.bo[ev.buf].buflisted = false

              -- Set filetype and manually attach LSP
              vim.bo[ev.buf].filetype = 'slang'

              -- Set up fallback search-based navigation for synthetic buffers
              vim.schedule(function()
                -- Disable semantic tokens for synthetic buffers (they cause errors)
                vim.b[ev.buf].semantic_tokens = false

                -- Attach LSP client
                local clients = vim.lsp.get_clients { name = 'slangd' }
                if #clients > 0 then
                  vim.lsp.buf_attach_client(ev.buf, clients[1].id)
                end

                -- Add buffer-local keybinding for fallback go-to-definition with picker
                vim.keymap.set('n', 'gd', function()
                  -- Get word under cursor
                  local word = vim.fn.expand '<cword>'
                  if word == '' then
                    return
                  end

                  local bufnr = vim.api.nvim_get_current_buf()
                  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                  local matches = {}

                  -- Collect all matches with smarter categorization
                  for i, line in ipairs(lines) do
                    local trimmed = line:gsub('^%s+', '')

                    -- Only match lines that actually contain the word
                    if not trimmed:match('%f[%w]' .. word .. '%f[%W]') then
                      goto continue
                    end

                    local match_type = 'reference'

                    -- Check what kind of definition this is
                    if trimmed:match('^struct%s+' .. word) then
                      match_type = 'struct'
                    elseif trimmed:match('^class%s+' .. word) then
                      match_type = 'class'
                    elseif trimmed:match('^interface%s+' .. word) then
                      match_type = 'interface'
                    elseif trimmed:match('^typedef%s+.*%s+' .. word) or trimmed:match('^typedef%s+' .. word) then
                      match_type = 'typedef'
                    elseif trimmed:match('^typealias%s+' .. word) then
                      match_type = 'typealias'
                    elseif trimmed:match('^enum%s+' .. word) then
                      match_type = 'enum'
                    elseif trimmed:match('%s+' .. word .. '%s*%(') or trimmed:match('^' .. word .. '%s*%(') then
                      match_type = 'function'
                    elseif trimmed:match('^%w+%s+' .. word .. '%s*[;=]') then
                      match_type = 'variable'
                    elseif trimmed:match('%s+' .. word .. '%s*:') then
                      match_type = 'member'
                    end

                    -- Skip pure reference matches unless they look significant
                    if match_type == 'reference' and not trimmed:match('^/') then
                      -- Skip comment-only references
                      goto continue
                    end

                    table.insert(matches, {
                      lnum = i,
                      col = 1,
                      text = trimmed:sub(1, 80), -- Truncate to 80 chars
                      type = match_type,
                    })

                    ::continue::
                  end

                  if #matches == 0 then
                    vim.notify('No definition found for: ' .. word, vim.log.levels.WARN)
                    return
                  end

                  if #matches == 1 then
                    -- Only one match, jump directly
                    vim.api.nvim_win_set_cursor(0, { matches[1].lnum, 0 })
                    vim.cmd 'normal! zz'
                    return
                  end

                  -- Sort: definitions first, then references
                  local priority = {
                    struct = 1,
                    class = 2,
                    interface = 3,
                    typedef = 4,
                    typealias = 5,
                    ['enum'] = 6,
                    ['function'] = 7,
                    variable = 8,
                    member = 9,
                    reference = 10,
                  }
                  table.sort(matches, function(a, b)
                    local pa = priority[a.type] or 10
                    local pb = priority[b.type] or 10
                    if pa == pb then
                      return a.lnum < b.lnum
                    end
                    return pa < pb
                  end)

                  -- Multiple matches - show in picker with compact format
                  local items = {}
                  for _, match in ipairs(matches) do
                    local icon = match.type == 'reference' and '→' or '●'
                    table.insert(items, {
                      text = string.format('%s %d  %s', icon, match.lnum, match.text),
                      lnum = match.lnum,
                      col = match.col,
                      bufnr = bufnr,
                    })
                  end

                  vim.ui.select(items, {
                    prompt = 'Select definition for ' .. word .. ':',
                    format_item = function(item)
                      return item.text
                    end,
                  }, function(choice)
                    if choice then
                      vim.api.nvim_win_set_cursor(0, { choice.lnum, choice.col - 1 })
                      vim.cmd 'normal! zz'
                    end
                  end)
                end, { buffer = ev.buf, desc = 'Go to definition (search-based)' })

                -- Add find references functionality
                vim.keymap.set('n', 'gr', function()
                  local word = vim.fn.expand '<cword>'
                  if word == '' then
                    return
                  end

                  -- Only allow identifiers (using treesitter)
                  local ok, node = pcall(vim.treesitter.get_node)
                  if ok and node then
                    local node_type = node:type()
                    -- Only proceed if it's an identifier (not a keyword/specifier/etc)
                    if not (node_type:match('identifier') or node_type:match('name')) then
                      return
                    end
                  end

                  local bufnr = vim.api.nvim_get_current_buf()
                  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                  local current_line = vim.api.nvim_win_get_cursor(0)[1]
                  local references = {}

                  -- Find all references (using word boundaries)
                  for i, line in ipairs(lines) do
                    if i ~= current_line and line:match('%f[%w]' .. word .. '%f[%W]') then
                      table.insert(references, {
                        lnum = i,
                        col = 1,
                        text = line:gsub('^%s+', ''):sub(1, 80),
                      })
                    end
                  end

                  if #references == 0 then
                    vim.notify('No references found for: ' .. word, vim.log.levels.WARN)
                    return
                  end

                  if #references == 1 then
                    vim.api.nvim_win_set_cursor(0, { references[1].lnum, 0 })
                    vim.cmd 'normal! zz'
                    return
                  end

                  -- Show in picker
                  local items = {}
                  for _, ref in ipairs(references) do
                    table.insert(items, {
                      text = string.format('→ %d  %s', ref.lnum, ref.text),
                      lnum = ref.lnum,
                      col = ref.col,
                      bufnr = bufnr,
                    })
                  end

                  vim.ui.select(items, {
                    prompt = string.format('References to %s (%d found):', word, #references),
                    format_item = function(item)
                      return item.text
                    end,
                  }, function(choice)
                    if choice then
                      vim.api.nvim_win_set_cursor(0, { choice.lnum, choice.col - 1 })
                      vim.cmd 'normal! zz'
                    end
                  end)
                end, { buffer = ev.buf, desc = 'Find references (search-based)' })

                -- Also override other common LSP keybindings
                vim.keymap.set('n', '<C-]>', function()
                  vim.cmd 'normal! gd'
                end, { buffer = ev.buf, desc = 'Go to definition' })
              end)
            else
              vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, {
                '// Error fetching module: ' .. module_name,
                '// ' .. (obj.stderr or 'Unknown error'),
              })
            end
          end
        end,
      })

      vim.lsp.config('slangd', {
        capabilities = slangd_capabilities,
        filetypes = { 'slang', 'shaderslang' },
        cmd = { vulkan_sdk .. '/bin/slangd' },
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local root = vim.fs.root(fname, {
            '.git',
            'slangdconfig.json',
            'slang.json',
            'CMakeLists.txt',
            'Makefile',
          })
          if root then
            on_dir(root)
          else
            -- Support standalone slang files
            on_dir(vim.fn.fnamemodify(fname, ':p:h'))
          end
        end,
        settings = {
          slang = {
            additionalSearchPaths = {
              vulkan_sdk .. '/bin',
              vulkan_sdk .. '/lib/slang-standard-module-2026.1',
            },
            inlayHints = {
              deducedTypes = true,
              parameterNames = true,
            },
          },
        },
      })

      -- Disable semantic tokens for slangd (causes errors with synthetic buffers)
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == 'slangd' then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })
      vim.lsp.config('nixd', { capabilities = capabilities })

      -- neocmakelsp configuration
      vim.lsp.config('neocmake', {
        cmd = { vim.fn.stdpath 'data' .. '/mason/bin/neocmakelsp', 'stdio' },
        filetypes = { 'cmake' },
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local root = vim.fs.root(fname, '.git')
          if root then
            on_dir(root)
          else
            -- Support standalone CMake files
            on_dir(vim.fn.fnamemodify(fname, ':p:h'))
          end
        end,
        init_options = {
          format = {
            enable = true,
          },
          lint = {
            enable = true,
          },
          scan_cmake_in_package = true,
        },
      })

      -- Enable all configured LSP servers
      for server, _ in pairs(opts.servers) do
        vim.lsp.enable(server)
      end
      vim.lsp.enable 'slangd'
      vim.lsp.enable 'neocmake'
    end,
  },
}
