{ ... }:
{
  flake.homeModules.helium =
    {
      config,
      pkgs,
      ...
    }:
    let
      version = "0.10.7.1";
      src = pkgs.fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
        hash = "sha256-+vmxXcg8TkR/GAiHKnjq4b04bGtQzErfJkOb4P4nZUk=";
      };
      helium-unwrapped = pkgs.appimageTools.wrapType2 {
        pname = "helium";
        inherit version src;
        extraPkgs = pkgs: [ ];
      };
      helium = config.lib.nixGL.wrap helium-unwrapped;
    in
    {
      home.packages = [ helium ];

      xdg.desktopEntries.helium = {
        name = "Helium";
        genericName = "Web Browser";
        exec = "${helium}/bin/helium %U";
        terminal = false;
        type = "Application";
        categories = [
          "Network"
          "WebBrowser"
        ];
        mimeType = [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
      };
    };
}
