return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    {
      -- https://github.com/ray-x/lsp_signature.nvim
      'ray-x/lsp_signature.nvim',
      event = 'VeryLazy',
      config = function()
        local cfg = {
          debug = false, -- set to true to enable debug logging
          log_path = vim.fn.stdpath 'cache' .. '/lsp_signature.log', -- log dir when debug is on
          -- default is  ~/.cache/nvim/lsp_signature.log
          verbose = false, -- show debug line number

          bind = true, -- This is mandatory, otherwise border config won't get registered.
          -- If you want to hook lspsaga or other signature handler, pls set to false
          doc_lines = 10, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
          -- set to 0 if you DO NOT want any API comments be shown
          -- This setting only take effect in insert mode, it does not affect signature help in normal
          -- mode, 10 by default

          max_height = 12, -- max height of signature floating_window
          max_width = 80, -- max_width of signature floating_window, line will be wrapped if exceed max_width
          -- the value need >= 40
          wrap = true, -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long
          floating_window = true, -- show hint in a floating window, set to false for virtual text only mode

          floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
          -- will set to true when fully tested, set to false will use whichever side has more space
          -- this setting will be helpful if you do not want the PUM and floating win overlap

          floating_window_off_x = 1, -- adjust float windows x position.
          -- can be either a number or function
          floating_window_off_y = 0, -- adjust float windows y position. e.g -2 move window up 2 lines; 2 move down 2 lines
          -- can be either number or function, see examples

          close_timeout = 4000, -- close floating window after ms when laster parameter is entered
          fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
          hint_enable = false, -- virtual hint enable
          hint_prefix = '🐼 ', -- Panda for parameter, NOTE: for the terminal not support emoji, might crash
          hint_scheme = 'String',
          hint_inline = function()
            return false
          end, -- should the hint be inline(nvim 0.10 only)?  default false
          -- return true | 'inline' to show hint inline, return 'eol' to show hint at end of line, return false to disable
          -- return 'right_align' to display hint right aligned in the current line
          hi_parameter = 'LspSignatureActiveParameter', -- how your parameter will be highlight
          handler_opts = {
            border = 'rounded', -- double, rounded, single, shadow, none, or a table of borders
          },

          always_trigger = false, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

          auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
          extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
          zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

          padding = '', -- character to pad on left and right of signature can be ' ', or '|'  etc

          transparency = nil, -- disabled by default, allow floating win transparent value 1~100
          shadow_blend = 36, -- if you using shadow as border use this set the opacity
          shadow_guibg = 'Black', -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
          timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
          toggle_key = nil, -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
          toggle_key_flip_floatwin_setting = false, -- true: toggle floating_windows: true|false setting after toggle key pressed
          -- false: floating_windows setup will not change, toggle_key will pop up signature helper, but signature
          -- may not popup when typing depends on floating_window setting

          select_signature_key = nil, -- cycle to next signature, e.g. '<M-n>' function overloading
          move_cursor_key = nil, -- imap, use nvim_set_current_win to move cursor between current win and floating
        }

        require('lsp_signature').setup(cfg) -- no need to specify bufnr if you don't use toggle_key
      end,
    },

    -- Useful status updates for LSP.
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', opts = {} },
  },
  config = function()
    --  This function gets run when an LSP attaches to a particular buffer.
    --    That is to say, every time a new file is opened that is associated with
    --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
    --    function will be executed to configure the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- NOTE: Remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself
        -- many times.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-T>.
        map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')

        -- Find references for the word under your cursor.
        map('gr', require('telescope.builtin').lsp_references, 'Goto References')

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type Definition')

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map('<leader>cs', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')

        -- Fuzzy find all the symbols in your current workspace
        --  Similar to document symbols, except searches over your whole project.
        map('<leader>cws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

        -- Rename the variable under your cursor
        --  Most Language Servers support renaming across files, etc.
        map('<leader>cr', vim.lsp.buf.rename, 'Rename')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')

        -- Opens a popup that displays documentation about the word under your cursor
        --  See `:help K` for why this keymap
        map('K', vim.lsp.buf.hover, 'Hover Documentation')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header
        map('gD', vim.lsp.buf.declaration, 'Goto Declaration')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
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

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP Specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. Available keys are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    local servers = {
      --cmake_language_server = {},
      codelldb = {},
      texlab = {},
      clangd = {
        -- cmd = {
        -- 'clangd',
        -- '--background-index',
        -- '--clang-tidy',
      },
      pyright = {},
      debugpy = {},
      ruff = {},
      rust_analyzer = {},
      lua_ls = {
        -- cmd = {...},
        -- filetypes { ...},
        -- capabilities = {},
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
    }

    -- Ensure the servers and tools above are installed
    --  To check the current status of installed tools and/or manually install
    --  other tools, you can run
    --    :Mason
    --
    --  You can press `g?` for help in this menu
    require('mason').setup()

    -- You can add other tools here that you want Mason to install
    -- for you, so that they are available from within Neovim.
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format lua code
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      -- ensure_installed = true,
      -- automatic_installation = true,
      ensure_installed = { 'lua_ls' },
      automatic_installation = true,
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          -- This handles overriding only values explicitly passed
          -- by the server configuration above. Useful when disabling
          -- certain features of an LSP (for example, turning off formatting for tsserver)
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
