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

        pkgs.jq
        pkgs.yq

        pkgs.zip
        pkgs.unzip
        pkgs.openssl

        pkgs.cargo
        pkgs.clippy
        pkgs.rustc
        pkgs.rustfmt
        pkgs.zig

        pkgs.gnumake
        pkgs.cmake

        pkgs.undollar
        pkgs.gdbgui
        pkgs.uv

        pkgs.ninja
        pkgs.gettext

      ];

      programs.bash.initExtra = ''
        export DEVENV_SHELL_TYPE=bash
      '';
      programs.zsh.initContent = ''
        export DEVENV_SHELL_TYPE=zsh
      '';
    };
}
