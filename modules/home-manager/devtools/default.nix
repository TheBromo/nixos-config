{ ... }:
{
  flake.homeModules.devtools =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.tree
        pkgs.gcc
        pkgs.nix-output-monitor
        pkgs.nixfmt
        pkgs.devenv
        pkgs.nixVersions.latest

        pkgs.jq
        pkgs.yq

        pkgs.zip
        pkgs.unzip
        pkgs.openssl

        pkgs.rustup
        pkgs.zig

        pkgs.gnumake
        pkgs.cmake

        pkgs.undollar
        pkgs.gdbgui
        pkgs.uv

        pkgs.ninja
        pkgs.gettext

      ];
    };
}
