{ ... }:
{
  flake.homeModules.devtools =
    { pkgs, lib, ... }:
    let
      # Native libraries used when fframes builds FFmpeg and its preview player.
      videoLibraries = [
        pkgs.ffmpeg
        pkgs.x264
        pkgs.x265
        pkgs.libopus
        pkgs.libvpx
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.alsa-lib ];
    in
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

        pkgs.pkg-config
        pkgs.nasm
        pkgs.yasm
        # Keep GCC's shared compiler aliases (cc/c++) while exposing clang.
        (lib.setPrio ((pkgs.gcc.meta.priority or 5) + 1) pkgs.llvmPackages.clang)

        pkgs.gnumake
        pkgs.cmake

        pkgs.undollar
        pkgs.gdbgui
        pkgs.uv

        pkgs.ninja
        pkgs.gettext

      ]
      ++ videoLibraries;

      home.sessionVariables = {
        PKG_CONFIG_PATH = lib.makeSearchPath "lib/pkgconfig" (map lib.getDev videoLibraries);
        LIBCLANG_PATH = "${lib.getLib pkgs.llvmPackages.libclang}/lib";
      };

      programs.bash.initExtra = ''
        export DEVENV_SHELL_TYPE=bash
      '';
      programs.zsh.initContent = ''
        export DEVENV_SHELL_TYPE=zsh
      '';
    };
}
