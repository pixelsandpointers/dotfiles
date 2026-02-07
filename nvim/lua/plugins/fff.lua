return {
  'dmtrKovalenko/fff.nvim',
  --build = 'cargo build --release',
  -- or if you are using nixos
  build = function()
    require('fff.download').download_or_build_binary()
  end,
  opts = {
    prompt = '>> ',
  },
  keys = {
    {
      '<leader><space>', -- try it if you didn't it is a banger keybinding for a picker
      function()
        require('fff').find_files() -- or find_in_git_root() if you only want git files
      end,
      desc = 'Open file picker',
    },
    {
      'ffo',
      function()
        require('fff').find_files_in_dir()
      end,
      desc = 'Find files in directory',
    },
  },
}
