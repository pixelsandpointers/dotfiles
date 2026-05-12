final: prev:
let
  inherit (prev.lib) optionalAttrs;
in {
  zotero = if prev.stdenv.isDarwin then
    # --- macOS: install Zotero.app from the DMG ---
    prev.stdenvNoCC.mkDerivation (finalAttrs: let
      version = "7.0.28";  # <- set the latest release
      dmgUrl  = "https://download.zotero.org/client/release/${version}/Zotero-${version}.dmg";    in {
      pname = "zotero";
      inherit version;

      src = prev.fetchurl {
        url  = dmgUrl;
        hash  = "sha256-scX59oUUGGzwQQLhnAq3tC6f1ttWUTlI0TfmXoA7+Uc=";
      };

      nativeBuildInputs = [ prev.undmg ];

      # DMG contains Zotero.app at the root
      sourceRoot = ".";

      installPhase = ''
        mkdir -p "$out/Applications"
        # find the app in case the DMG volume name changes
        app="$(find . -maxdepth 2 -name 'Zotero.app' -type d | head -n1)"
        if [ -z "$app" ]; then
          echo "Zotero.app not found in DMG contents"; exit 1
        fi
        cp -R "$app" "$out/Applications/"
        # convenience wrapper so you can `zotero` in PATH
        mkdir -p "$out/bin"
        cat > "$out/bin/zotero" <<'EOF'
        #!/usr/bin/env bash
        open "$0/../Applications/Zotero.app" "$@"
        EOF
        chmod +x "$out/bin/zotero"
      '';

      meta = with prev.lib; {
        description = "Zotero for macOS (installed from official DMG)";
        homepage    = "https://www.zotero.org/";
        license     = licenses.unfree;  # upstream binary
        platforms   = platforms.darwin;
        mainProgram = "zotero";
      };
    })
  else
    # --- Linux: just bump version/src of the existing package ---
    prev.zotero.overrideAttrs (old: let
      version = "7.0.27"; # <- same version
      tarUrl  = "https://download.zotero.org/client/release/${version}/Zotero-${version}_linux-x86_64.tar.bz2";
    in {
      inherit version;
      src = prev.fetchurl {
        url  = tarUrl;
        hash = "sha256-REPLACE_ME"; # prefetch & fill
      };
    });
}
