return {
  {
    'saghen/blink.cmp',
    dependencies = {
      { 'rafamadriz/friendly-snippets' },
      { 'L3MON4D3/LuaSnip', version = 'v2.*' },
    },

    version = '1.*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'enter',
        ['<Tab>'] = {
          function(cmp)
            -- check if completion window is open
            if cmp.is_active() then
              return cmp.select_next()
            end
          end,
          'snippet_forward',
          'fallback',
        },
        ['<S-Tab>'] = {
          function(cmp)
            -- check if completion window is open
            if cmp.is_active() then
              return cmp.select_prev()
            end
          end,
          'snippet_backward',
          'fallback',
        },
        ['<C-e>'] = { 'hide', 'fallback' },
      },

      cmdline = {
        enabled = true,
      },
      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        trigger = {
          show_on_insert_on_trigger_character = false,
        },
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        },
        ghost_text = {
          enabled = true,
        },
        keyword = {
          range = 'full',
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      snippets = {
        preset = 'luasnip',
      },

      signature = {
        enabled = true,
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },

  -- snippets
  {
    'L3MON4D3/LuaSnip',
    build = 'make install_jsregexp',
    event = 'InsertEnter',
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = 'TextChanged',
    },
    config = function(_, opts)
      require('luasnip').setup(opts)
    end,
    -- stylua: ignore
    keys = function()
      return {}
    end,
  },
  {
    'iurimateus/luasnip-latex-snippets.nvim',
    dependencies = { 'L3MON4D3/LuaSnip', 'lervag/vimtex' },
    ft = { 'tex', 'markdown' },
    config = function()
      require('luasnip').config.setup { enable_autosnippets = true }

      -- Patch treesitter detection to support markdown $ $ syntax
      local ts_utils = require 'luasnip-latex-snippets.util.ts_utils'
      local original_in_mathzone = ts_utils.in_mathzone

      ts_utils.in_mathzone = function()
        -- Use regex detection for markdown
        if vim.bo.filetype == 'markdown' or vim.bo.filetype == 'quarto' then
          return require('utils').in_mathzone()
        end
        -- Use original treesitter detection for LaTeX
        return original_in_mathzone()
      end

      -- Setup plugin with markdown support
      require('luasnip-latex-snippets').setup {
        use_treesitter = false, -- vimtex for LaTeX
        allow_on_markdown = true, -- but markdown will use our patched detection
      }
    end,
  },
}
