{
  description = "MacOS Nix Build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
    let
      configuration = { pkgs, config, ... }: let
      in {
	nixpkgs.config.allowUnfree = true;
	nixpkgs.hostPlatform = "aarch64-darwin";

	homebrew = {
	  enable = true;
	  onActivation.cleanup = "zap";
	  taps = [
	    "FelixKratz/formulae"
	  ];

	  brews = [
	    "assimp"
	    "borders"
	    "pngpaste"
	    "z"
	  ];

	  casks = [
	    # fonts 
	    "font-roboto-mono-nerd-font"
	    "font-meslo-lg-nerd-font"

	    # dev tools
	    "nikitabobko/tap/aerospace"
	    "warp"
	    "raycast"
	    "jetbrains-toolbox"
	    "cmake" # => should include the GUI version as well
	    "docker"
	    "keycastr"

	    # coms
	    "signal"
	    "zoom"
	    "loom"

	    # dcc
	    "godot"
  
	    # misc
	    "inkscape"
	    "steam"
	    "emacs"
	    "thunderbird"
	    "proton-drive"
	    "obsidian"
	  ];

	  # INFO: only enable them once, because MAS apps
	  # will be reinstalled everytime
	  # masApps = {
	  #   Keynote = 409183694;
	  #   Kindle = 302584613;
	  #   LINE = 443904275;
	  #   Word = 462054704;
	  #   Excel = 462058435;
	  #   PowerPoint = 462062816;
	  #   Xcode = 497799835;
	  #   Todoist = 585829637;
	  #   Goodnotes = 1444383602;
	  #   "ZSA Keymapp" = 6472865291;
	  # };
	};


	environment.systemPackages = with pkgs; [
	  # Git
	  git
	  git-lfs
	  gh
	  lazygit

	  # Shell
	  tmux
	  oh-my-zsh
	  nushell
	  zsh-z

	  # CLI
	  bat
	  chafa
	  dwt1-shell-color-scripts
	  htop
	  wget

	  # NVim
	  neovim
	  ripgrep
	  fd
	  fzf
	  tree-sitter
	  graphviz

	  # NIX
	  direnv
	  fh
	  mas

	  # C++
	  ccache
	  ninja
	  clang-tools
	  cmake-language-server
	  llvm
	  lldb
	  libllvm  # need to manually set LD_LIBRARY_PATH

	  # Rust 
	  rustup

	  # Python
	  python3
	  marimo
	  ruff
	  uv

	  # Node
	  nodejs_22

	  # PDF Tools 
	  noweb
	  pkg-config
	  poppler
	  autoconf
	  automake
	  imagemagick
	  jpegoptim

	  # GUI
	  mkalias
	  anki-bin
	  discord
	  vscode
	  zotero
	];

	fonts.packages = with pkgs; [
	  nerd-fonts.jetbrains-mono
	  nerd-fonts.blex-mono
	  libertine
	];

	# Necessary for using flakes on this system.
	nix.settings.experimental-features = "nix-command flakes";

	# Enable alternative shell support in nix-darwin.
	programs.zsh.enable = true;

	# Set Git commit hash for darwin-version.
	system.primaryUser = "b";
	system.configurationRevision = self.rev or self.dirtyRev or null;

	# set up aliases
	system.activationScripts.applications.text = let
	  env = pkgs.buildEnv {
	    name = "system-applications";
	    paths = config.environment.systemPackages;
	    pathsToLink = "/Applications";
	  };
	in
	  pkgs.lib.mkForce ''
	  # Set up applications.
	  echo "setting up /Applications..." >&2
	  rm -rf /Applications/Nix\ Apps
	  mkdir -p /Applications/Nix\ Apps
	  find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
	  while read -r src; do
	    app_name=$(basename "$src")
	    echo "copying $src" >&2
	    ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
	  done
	  '';

	# Used for backwards compatibility, please read the changelog before changing.
	# $ darwin-rebuild changelog
	system.stateVersion = 5;
	system.defaults = {
	  dock.autohide = true;
	  dock.persistent-apps = [
	    "/System/Applications/Music.app"
	    "/Applications/Brave Browser.app"
	    "/Applications/Keynote.app"
	    "/Applications/Adobe Photoshop 2025/Adobe Photoshop 2025.app"
	    "/Applications/Adobe Lightroom Classic/Adobe Lightroom Classic.app"
	    "/Applications/Adobe Illustrator 2025/Adobe Illustrator.app"
	    "/Applications/Adobe InDesign 2025/Adobe InDesign 2025.app"
	    "${pkgs.zotero}/Applications/Zotero.app"
	    "/Applications/Obsidian.app"
	    "/Applications/Ghostty.app"
	    "/Applications/Warp.app"
	    "/Applications/Blender.app"
	    "/Users/Shared/Epic Games/UE_5.6/Engine/Binaries/Mac/UnrealEditor.app"
	  ];

	  finder.FXPreferredViewStyle = "clmv";
	  NSGlobalDomain.AppleInterfaceStyle = "Dark";
	};
      };
    in
      {
      darwinConfigurations."zen" = nix-darwin.lib.darwinSystem {
	modules = [
	  configuration
	  nix-homebrew.darwinModules.nix-homebrew
	  {
	    nix-homebrew = {
	      enable = true;
	      enableRosetta = true;
	      user = "b";
	      autoMigrate = true;
	    };
	  }
	];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."zen".pkgs;
    };
}
