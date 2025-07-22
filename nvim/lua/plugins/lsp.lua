return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'saghen/blink.cmp',
    -- {
    --   -- https://github.com/ray-x/lsp_signature.nvim
    --   'ray-x/lsp_signature.nvim',
    --   event = 'VeryLazy',
    --   config = function()
    --     local cfg = {
    --       debug = false, -- set to true to enable debug logging
    --       log_path = vim.fn.stdpath 'cache' .. '/lsp_signature.log', -- log dir when debug is on
    --       -- default is  ~/.cache/nvim/lsp_signature.log
    --       verbose = false, -- show debug line number
    --
    --       bind = true, -- This is mandatory, otherwise border config won't get registered.
    --       -- If you want to hook lspsaga or other signature handler, pls set to false
    --       doc_lines = 10, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
    --       -- set to 0 if you DO NOT want any API comments be shown
    --       -- This setting only take effect in insert mode, it does not affect signature help in normal
    --       -- mode, 10 by default
    --
    --       max_height = 12, -- max height of signature floating_window
    --       max_width = 80, -- max_width of signature floating_window, line will be wrapped if exceed max_width
    --       -- the value need >= 40
    --       wrap = true, -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long
    --       floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
    --
    --       floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
    --       -- will set to true when fully tested, set to false will use whichever side has more space
    --       -- this setting will be helpful if you do not want the PUM and floating win overlap
    --
    --       floating_window_off_x = 1, -- adjust float windows x position.
    --       -- can be either a number or function
    --       floating_window_off_y = 0, -- adjust float windows y position. e.g -2 move window up 2 lines; 2 move down 2 lines
    --       -- can be either number or function, see examples
    --
    --       close_timeout = 4000, -- close floating window after ms when laster parameter is entered
    --       fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
    --       hint_enable = false, -- virtual hint enable
    --       hint_prefix = '🐼 ', -- Panda for parameter, NOTE: for the terminal not support emoji, might crash
    --       hint_scheme = 'String',
    --       hint_inline = function()
    --         return false
    --       end, -- should the hint be inline(nvim 0.10 only)?  default false
    --       -- return true | 'inline' to show hint inline, return 'eol' to show hint at end of line, return false to disable
    --       -- return 'right_align' to display hint right aligned in the current line
    --       hi_parameter = 'LspSignatureActiveParameter', -- how your parameter will be highlight
    --       handler_opts = {
    --         border = 'rounded', -- double, rounded, single, shadow, none, or a table of borders
    --       },
    --
    --       always_trigger = false, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58
    --
    --       auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
    --       extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
    --       zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom
    --
    --       padding = '', -- character to pad on left and right of signature can be ' ', or '|'  etc
    --
    --       transparency = nil, -- disabled by default, allow floating win transparent value 1~100
    --       shadow_blend = 36, -- if you using shadow as border use this set the opacity
    --       shadow_guibg = 'Black', -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
    --       timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
    --       toggle_key = nil, -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
    --       toggle_key_flip_floatwin_setting = false, -- true: toggle floating_windows: true|false setting after toggle key pressed
    --       -- false: floating_windows setup will not change, toggle_key will pop up signature helper, but signature
    --       -- may not popup when typing depends on floating_window setting
    --
    --       select_signature_key = nil, -- cycle to next signature, e.g. '<M-n>' function overloading
    --       move_cursor_key = nil, -- imap, use nvim_set_current_win to move cursor between current win and floating
    --     }
    --
    --     require('lsp_signature').setup(cfg) -- no need to specify bufnr if you don't use toggle_key
    --   end,
    -- },

    -- Useful status updates for LSP.
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', opts = {} },
  },
  opts = {
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
    -- vim.tbl_deep_extend('force', capabilities, {
    --   workspace = {
    --     didChangeWatchedFiles = {
    --       dynamicRegistration = true,
    --     },
    --   },
    -- })
    --lspconfig['sourcekit'].setup { capabilities = capabilities }
  end,
}
