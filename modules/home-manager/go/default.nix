{ ... }:
{
  flake.homeModules.go =
    { lib, pkgs, ... }:
    {

      home = {
        packages = [
          pkgs.go
          pkgs.gopls
          (lib.lowPrio pkgs.gotools)
        ];
        sessionPath = lib.mkAfter [ "$HOME/go/bin" ];
        sessionVariables.GOPATH = "$HOME/go";
      };
    };
}
