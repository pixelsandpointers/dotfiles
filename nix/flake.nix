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
	# FIXME: tex xis not recognized as a variable, which is valid because it is not used in in
	# This will probably need to rewritten, that we pass the combined package into
	# the environment systemPackages. For now, live without biblatex.
	# tex = texlive.withPackages (ps: [ps.biblatex ps.collection-bibtexextra]);
	# tex = pkgs.texlive.combine {
	#   inherit (pkgs.texlive) scheme-full latexmk biblatex;
	#};
      in {
	# List packages installed in system profile. To search by name, run:
	# $ nix-env -qaP | grep wget

	# The platform the configuration will be used on.
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
	    "helix"
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
	  # System
	  oh-my-zsh
	  tmux
	  git
	  git-lfs
	  gh
	  graphviz
	  mas
	  htop
	  wget
	  direnv
	  tree-sitter
	  ripgrep
	  fd
	  lazygit
	  fh
	  fzf
	  zsh-z

	  # Programming
	  neovim
	  ccache
	  ninja
	  clang-tools
	  cmake-language-server
	  llvm
	  lldb
	  libllvm  # need to manually set LD_LIBRARY_PATH
	  rustup
	  python3
	  marimo
	  ruff
	  uv
	  nodejs_22

	  # PDF Tools 
	  pkg-config
	  poppler
	  autoconf
	  automake
	  imagemagick
	  jpegoptim

	  # GUI apps, may want to put them into casks for the sake of findability
	  mkalias # required for GUI applications to show up in Finder using aliases
	  anki-bin
	  brave
	  discord
	  vscode
	  zotero

	  # VFX
	  openexr
	  openusd
	  python312Packages.openusd
	];

	fonts.packages = with pkgs; [
	  nerd-fonts.jetbrains-mono
	  nerd-fonts.blex-mono
	  libertine
	];

	# Necessary for using flakes on this system.
	nix.settings.experimental-features = "nix-command flakes";

	# Enable alternative shell support in nix-darwin.
	# programs.fish.enable = true;
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
	    # FIXME: "/Applications/Music.app"
	    "/Applications/Brave Browser.app"
	    "${pkgs.zotero}/Applications/Zotero.app"
	    "/Applications/Obsidian.app"
	    "/Applications/Ghostty.app"
	    "/Users/b/Applications/PyCharm.app"
	    "/Users/b/Applications/CLion.app"
	    "/Users/b/Applications/Rider.app"
	    "/Applications/Blender.app"
	    "/Users/Shared/Epic Games/UE_5.5/Engine/Binaries/Mac/UnrealEditor.app"
	    "/Applications/Adobe Photoshop 2025/Adobe Photoshop 2025.app"
	    "/Applications/Adobe Lightroom CC/Adobe Lightroom.app"
	  ];

	  finder.FXPreferredViewStyle = "clmv";
	  NSGlobalDomain.AppleInterfaceStyle = "Dark";
	};
      };
    in
      {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
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
