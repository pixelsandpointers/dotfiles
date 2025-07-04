return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for install instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of help_tags options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      -- defaults = {
      --   mappings = {
      --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
      --   },
      -- },
      -- pickers = {}
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_ivy(),
        },
      },
    }

    -- Enable telescope extensions, if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local builtin = require 'telescope.builtin'
    local themes = require 'telescope.themes'

    vim.keymap.set('n', '<leader>f.', builtin.builtin, { desc = 'Find builtin methods' })
    vim.keymap.set('n', '<leader>fm', builtin.marks, { desc = 'Find Marks' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help' })
    vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Find Keymaps' })
    vim.keymap.set('n', '<leader><space>', builtin.find_files, { desc = 'Find Files' })
    vim.keymap.set('n', '<leader>fa', builtin.lsp_workspace_symbols, { desc = 'Find Workspace Symbols' })
    vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find current Word' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find by Grep' })
    vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Find Diagnostics' })
    vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Find Resume' })
    vim.keymap.set('n', '<leader>ff', builtin.oldfiles, { desc = 'Find Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Existing Buffers' })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>fs', function()
      builtin.lsp_document_symbols(themes.get_ivy { desc = 'Find Document Symbols' })
    end, { desc = 'Find Document Symbols' })

    vim.keymap.set('n', '<leader>fa', function()
      builtin.lsp_workspace_symbols(themes.get_ivy { desc = 'Find Workspace Symbols' })
    end, { desc = 'Find Workspace Symbols' })

    vim.keymap.set('n', '<leader>fo', function()
      builtin.find_files(themes.get_ivy { cwd = '~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault' })
    end, { desc = 'Find file in Obsidian fault' })

    -- Shortcut for searching your neovim configuration files
    vim.keymap.set('n', '<leader>fp', function()
      builtin.find_files { cwd = '~/.config' }
    end, { desc = 'Find Private Config files' })

    vim.keymap.set('n', '<leader>fn', function()
      builtin.find_files(themes.get_ivy { cwd = '~/.config/nvim' })
    end, { desc = 'Find Neovim Files' })
  end,
}
