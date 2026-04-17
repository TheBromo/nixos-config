# To update:
#   1. Change `version` below
#   2. Set hash to empty string: hash = "";
#   3. Run: nix build .#homeConfigurations.<host>.activationPackage
#   4. Copy the correct hash from the error message
{ ... }:
{
  flake.homeModules.t3code =
    {
      config,
      pkgs,
      ...
    }:
    let
      version = "0.0.20";
      src = pkgs.fetchurl {
        url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
        hash = "sha256-glYnF8UA5s4rrpUJuvk4HlQtyMikbckIkmMIhnJugO4=";
      };
      t3code-unwrapped = pkgs.appimageTools.wrapType2 {
        pname = "t3code";
        inherit version src;
        extraPkgs = pkgs: [ ];
      };
      t3code = config.lib.nixGL.wrap t3code-unwrapped;
      icon = pkgs.fetchurl {
        url = "https://media.brand.dev/64c8e868-1600-4dbb-aa50-d4654494a909.png";
        hash = "sha256-YKVruRilE0x45yTSenJ1eLcedTF2Px1/o0V0Clws0dY=";
      };
    in
    {
      home.packages = [ t3code ];

      home.file.".local/share/icons/hicolor/512x512/apps/t3code.png".source = icon;

      xdg.desktopEntries.t3code = {
        name = "T3 Code";
        genericName = "Code Editor";
        exec = "${t3code}/bin/t3code %U";
        icon = "t3code";
        terminal = false;
        type = "Application";
        categories = [
          "Development"
          "IDE"
          "TextEditor"
        ];
        mimeType = [
          "text/plain"
        ];
      };
    };
}
