{ self, inputs, ... }:
{
  flake.homeModules.go =
    { pkgs, ... }:
    {

      home.packages = [
        pkgs.go
        pkgs.gopls
        pkgs.gotools
      ];

      programs.zsh.initContent = ''
        export GOPATH=$HOME/go
        export PATH=$PATH:$HOME/go/bin
      '';
    };
}
