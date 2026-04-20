{ ... }:
{
  flake.homeModules.go =
    { lib, pkgs, ... }:
    {

      home.packages = [
        pkgs.go
        pkgs.gopls
        (lib.lowPrio pkgs.gotools)
      ];

      programs.zsh.initContent = ''
        export GOPATH=$HOME/go
        export PATH=$PATH:$HOME/go/bin
      '';
    };
}
