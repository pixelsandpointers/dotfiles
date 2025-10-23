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
          brews = [ "assimp" "borders" "colmap" "imagemagick" "pngpaste" "fzf" "zoxide" ];
          casks = [
            "font-roboto-mono-nerd-font"
            "font-meslo-lg-nerd-font"
            "font-ubuntu-mono-nerd-font"
            "nikitabobko/tap/aerospace"
            "warp" "raycast" "jetbrains-toolbox" "cmake" "docker" "keycastr"
            "signal" "zoom" "loom"
            "godot" "tev"
            "inkscape" "steam" "thunderbird" "obsidian"
          ];
        };

        # Overlays
        nixpkgs.overlays = [ (import ./overlays/overlay-zotero-latest.nix) ];

        environment.systemPackages = with pkgs; [
          git git-lfs gh lazygit jujutsu lazyjj
          tmux oh-my-zsh nushell zsh-z
          bat chafa dwt1-shell-color-scripts htop wget yazi
          neovim ripgrep fd fzf tree-sitter graphviz
          nixpkgs-fmt direnv fh mas ns
          # FIX: reference hyphenated attr via pkgs."…"
          (inputs.nix-search-tv.packages.${pkgs.system}.default)
          ccache ninja clang-tools llvm lldb libllvm
          rustup zig
          (python3.withPackages (ps: with ps; [ uv ]))
          nodejs_22
          noweb gnuplot pkg-config poppler autoconf automake jpegoptim
          mkalias anki-bin discord vscode zotero
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
            pathsToLink = "/Applications";
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
            "/Applications/Keynote.app"
            "/Applications/Obsidian.app"
            "/Applications/Ghostty.app"
            "/Applications/Warp.app"
            "/Applications/Xcode.app/"
            "/Applications/Xcode.app/Contents/Applications/Instruments.app"
            "/Applications/Adobe Photoshop 2025/Adobe Photoshop 2025.app"
            "/Applications/Adobe Lightroom Classic/Adobe Lightroom Classic.app"
            "/Applications/Adobe Illustrator 2025/Adobe Illustrator.app"
            "/Applications/Adobe InDesign 2025/Adobe InDesign 2025.app"
            "/Users/b/dev/blender-git/main_release_build/bin/Blender.app"
            "/Users/Shared/Epic Games/UE_5.6/Engine/Binaries/Mac/UnrealEditor.app"
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
