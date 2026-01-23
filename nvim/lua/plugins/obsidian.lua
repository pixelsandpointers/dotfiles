return {
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = 'markdown',
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
          vim.opt_local.shiftwidth = 4
          vim.opt_local.tabstop = 4
          vim.opt_local.expandtab = true
        end,
      })
    end,
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      'nvim-lua/plenary.nvim',

      -- see below for full list of optional dependencies 👇
    },
    keys = {
      { '<leader>mt', '<cmd>Obsidian today<cr>', desc = 'Today' },
      { '<leader>my', '<cmd>Obsidian yesterday<cr>', desc = 'Yesterday' },
      { '<leader>mo', '<cmd>Obsidian quick_switch<cr>', desc = 'Open note' },
      { '<leader>mn', '<cmd>Obsidian new<cr>', desc = 'New note' },
      { '<leader>ms', '<cmd>Obsidian search<cr>', desc = 'Search' },
      { '<leader>mb', '<cmd>Obsidian backlinks<cr>', desc = 'Backlinks' },
      { '<leader>ml', '<cmd>Obsidian links<cr>', desc = 'Links' },
      { '<leader>mg', '<cmd>Obsidian tags<cr>', desc = 'Tags' },
      { '<leader>mp', '<cmd>Obsidian paste_img<cr>', desc = 'Paste image' },
      { '<leader>mr', '<cmd>Obsidian rename<cr>', desc = 'Rename' },
      { '<leader>me', '<cmd>Obsidian template<cr>', desc = 'Insert template' },
    },
    opts = {
      completion = {
        blink = true,
      },
      workspaces = {
        {
          name = 'Vault',
          path = vim.fn.expand '~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault',
        },
        {
          name = 'Google Drive Vault',
          path = vim.fn.expand '~/Google Drive/My Drive/Vault',
        },
        {
          name = 'NixOS Cached Vault',
          path = vim.fn.expand '~/Vault/',
        },
        -- {
        --   name = 'labwiki',
        --   path = '~/lab/perception_wiki/',
        -- },
      },
      templates = {
        folder = '+ Templates',
      },
      daily_notes = {
        folder = '+ Dailies',
        date_format = '%Y-%m-%d-%a', -- e.g. 2025-09-22-Mon
        alias_format = '%B %-d, %Y', -- e.g. September 22, 2025
        template = 'daily_obs.md',
        default_tags = {},
      },
      legacy_commands = false,
      attachments = {
        img_folder = '+ Inbox/Images',
      },
    },
  },
  -- {
  --   '3rd/image.nvim',
  --   ft = 'markdown',
  --   opts = {
  --     backend = 'kitty',
  --     processor = 'magick_cli',
  --     integrations = {
  --       markdown = {
  --         enabled = true,
  --         clear_in_insert_mode = false,
  --         download_remote_images = true,
  --         only_render_image_at_cursor = true,
  --         only_render_image_at_cursor_mode = 'popup',
  --         floating_windows = false,
  --         filetypes = { 'markdown', 'vimwiki' },
  --       },
  --     },
  --     max_height_window_percentage = 50,
  --     window_overlap_clear_enabled = false,
  --     window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'snacks_notif', 'scrollview', 'scrollview_sign' },
  --     hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.avif' },
  --   },
  -- },
}
