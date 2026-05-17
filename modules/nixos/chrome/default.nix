{ ... }:
{
  flake.nixosModules.chrome =
    { config, pkgs, ... }:
    let
      googleChromeBin = pkgs.writeShellScriptBin "google-chrome" ''
        exec ${pkgs.google-chrome}/bin/google-chrome \
          --user-data-dir="$HOME/.config/google-chrome-${config.networking.hostName}" \
          "$@"
      '';
      googleChromeDesktop = pkgs.runCommand "google-chrome-desktop" { } ''
        mkdir -p $out/share/applications

        for desktopFile in google-chrome.desktop com.google.Chrome.desktop; do
          substitute ${pkgs.google-chrome}/share/applications/$desktopFile \
            $out/share/applications/$desktopFile \
            --replace-fail '${pkgs.google-chrome}/bin/google-chrome-stable' '${googleChromeBin}/bin/google-chrome'
        done

        ln -s ${pkgs.google-chrome}/share/icons $out/share/icons
      '';
      googleChromeWrapped = pkgs.symlinkJoin {
        name = "google-chrome";
        paths = [
          googleChromeBin
          googleChromeDesktop
        ];
      };
    in
    {
      users.users.manuel.packages = [
        googleChromeWrapped
      ];
    };
}
