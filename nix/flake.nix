{
  description = "MacOS Nix Build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-search-tv.url = "github:3timeslazy/nix-search-tv";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, nix-search-tv }:
    let
      configuration = { pkgs, config, ... }: let
        ns = pkgs.writeShellScriptBin "ns" (builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh");
      in {
        nixpkgs.config.allowUnfree = true;
        nixpkgs.hostPlatform = "aarch64-darwin";
        homebrew = {
          enable = true;
          onActivation.cleanup = "zap";
          taps = [ "FelixKratz/formulae" ];
          brews = [ "assimp" "borders" "glfw" "imagemagick" "pngpaste" "fzf" "zoxide" "sketchybar" ];
          casks = [
            "font-hack-nerd-font"
            "font-source-code-pro"
            "font-roboto-mono-nerd-font"
            "font-meslo-lg-nerd-font"
            "font-ubuntu-mono-nerd-font"
            "nikitabobko/tap/aerospace"
            "slack"
            "warp"
            "raycast"
            "jetbrains-toolbox" 
            "cmake"
            "docker"
            "keycastr"
            "signal"
            "zoom"
            "loom"
            "godot"
            "tev"
            "thunderbird"
            "obsidian"
          ];
        };

        # Overlays
        nixpkgs.overlays = [ (import ./overlays/overlay-zotero-latest.nix) ];

        environment.systemPackages = with pkgs; [
          git git-lfs gh lazygit
          tmux oh-my-zsh zsh-z
          bat chafa dwt1-shell-color-scripts htop wget yazi
          neovim ripgrep fd fzf tree-sitter graphviz
          nixpkgs-fmt devenv direnv nixd fh nh mas ns (inputs.nix-search-tv.packages.${pkgs.system}.default)
          ccache ninja clang-tools llvm lldb libllvm rustup claude-code
          (python3.withPackages (ps: with ps; [ uv ])) nodejs_22
          pkg-config poppler autoconf automake jpegoptim
          mkalias anki-bin discord vscode zotero nom
        ];

        fonts.packages = with pkgs; [
          nerd-fonts.fira-code
          nerd-fonts.jetbrains-mono
          nerd-fonts.blex-mono
          libertine
        ];

        nix.settings.experimental-features = "nix-command flakes";
        programs.zsh.enable = true;

        system.primaryUser = "b";
        system.configurationRevision = self.rev or self.dirtyRev or null;

        system.activationScripts.applications.text = let
          env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = [ "/Applications" ];
          };
        in pkgs.lib.mkForce ''
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

        system.stateVersion = 5;
        system.defaults = {
          dock.autohide = true;
          dock.persistent-apps = [
            "/System/Applications/Music.app"
            "/Applications/Brave Browser.app"
            "/Applications/Ghostty.app"
            "/Applications/Arm_Performance_Studio_2025.6/renderdoc_for_arm_gpus/RenderDoc.app"
            "/Applications/Adobe Lightroom Classic/Adobe Lightroom Classic.app"
            "/Applications/Blender45.app/"
            "/Applications/Houdini/Houdini21.0.512/Houdini Apprentice 21.0.512.app/"
          ];
          finder.FXPreferredViewStyle = "clmv";
          NSGlobalDomain.AppleInterfaceStyle = "Dark";
        };
      };
    in {
      darwinConfigurations."zen" = nix-darwin.lib.darwinSystem {
        modules = [
          ({ pkgs, ... }: {
            environment.systemPackages = [
              (nix-search-tv.packages.${pkgs.system}.default)
            ];
          })

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

      darwinPackages = self.darwinConfigurations."zen".pkgs;
    };
}
