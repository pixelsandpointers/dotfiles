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
	# nixpkgs.config.allowUnsupportedSystem = true;
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
	  ];

	  casks = [
	    "emacs"
	    "nikitabobko/tap/aerospace"
	    "proton-drive"
	    "signal"
	    "jetbrains-toolbox"
	    "zoom"
	    "blender"
	    "obsidian"
	  ];
	  masApps = {
	    Keynote = 409183694;
	    Kindle = 302584613;
	  };
	};


	environment.systemPackages = [
	  # System
	  pkgs.alacritty
	  pkgs.oh-my-posh
	  pkgs.mas
	  pkgs.htop
	  pkgs.ripgrep
	  pkgs.fd
	  pkgs.tmux
	  pkgs.git
	  pkgs.fh
	  pkgs.direnv
	  pkgs.gh

	  # Programming
	  pkgs.cmake
	  pkgs.llvm
	  pkgs.lldb
	  pkgs.libllvm  # need to manually set LD_LIBRARY_PATH
	  pkgs.rustup
	  pkgs.python3
	  pkgs.python312Packages.pip
	  pkgs.ruff
	  pkgs.uv
	  pkgs.nodejs_22
	  pkgs.hugo

	  # Editors
	  pkgs.neovim

	  # Latex
	  pkgs.texliveFull
	  (pkgs.texlive.withPackages(ps: with ps; [biblatex natbib latexmk bibtools]))
	  # Emacs PDF Tools Dependencies
	  pkgs.pkg-config
	  pkgs.poppler
	  pkgs.autoconf
	  pkgs.automake

	  # GUI apps, may want to put them into casks for the sake of findability
	  pkgs.mkalias # required for GUI applications to show up in Finder using aliases
	  pkgs.anki-bin
	  pkgs.brave
	  pkgs.discord
	  pkgs.element-desktop
	  pkgs.inkscape
	  pkgs.vscode
	  pkgs.zotero

	  # VFX
	  pkgs.assimp
	  pkgs.openexr
	  pkgs.openusd
	  pkgs.python312Packages.openusd
	];

	fonts.packages = [
	  (pkgs.nerdfonts.override {fonts = [ "JetBrainsMono" ]; })
	];

	services.nix-daemon.enable = true;

	# Necessary for using flakes on this system.
	nix.settings.experimental-features = "nix-command flakes";

	# Enable alternative shell support in nix-darwin.
	# programs.fish.enable = true;
	programs.zsh.enable = true;

	# Set Git commit hash for darwin-version.
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
			"/Applications/Music.app"
	    "/Applications/Emacs.app"
	    "/Applications/Brave Browser.app"
	    "${pkgs.zotero}/Applications/Zotero.app"
			"/Applications/Kindle.app"
			"/Applications/Keynote.app"
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
