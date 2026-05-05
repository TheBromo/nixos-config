# To update:
#   1. Change `version` below
#   2. Set hash to empty string: hash = "";
#   3. Run: nix build .#homeConfigurations.<host>.activationPackage
#   4. Copy the correct hash from the error message
{ ... }:
{
  flake.homeModules.headlamp =
    {
      config,
      pkgs,
      ...
    }:
    let
      version = "0.41.0";
      src = pkgs.fetchurl {
        url = "https://github.com/kubernetes-sigs/headlamp/releases/download/v${version}/Headlamp-${version}-linux-x64.AppImage";
        hash = "sha256-SdadGirmfSfj1gmbxc5IKRdwnHqkI4keSE0BlkKGW4c=";
      };
      headlamp-unwrapped = pkgs.appimageTools.wrapType2 {
        pname = "headlamp";
        inherit version src;
        extraPkgs = pkgs: [ ];
      };
      headlamp = config.lib.nixGL.wrap headlamp-unwrapped;
    in
    {
      home.packages = [ headlamp ];

      xdg.desktopEntries.headlamp = {
        name = "Headlamp";
        genericName = "Kubernetes UI";
        exec = "${headlamp}/bin/headlamp %U";
        terminal = false;
        type = "Application";
        categories = [
          "Development"
          "System"
        ];
        settings.StartupWMClass = "Headlamp";
      };
    };
}
