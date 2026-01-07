{ pkgs, ... }:
{
  environment.systemPackages = [
    # ...

    # support both 32- and 64-bit applications
    pkgs.wineWowPackages.stable

    # winetricks (all versions)
    pkgs.winetricks

    # native wayland support (unstable)
    pkgs.wineWowPackages.waylandFull
  ];
}
