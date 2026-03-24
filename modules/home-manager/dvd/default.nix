{ ... }:
{
  flake.homeModules.dvd =
    { pkgs, ... }:
    let
      dvd = pkgs.writeShellScriptBin "dvd" ''
        echo "use flake \"github:the-nix-way/dev-templates/d5ad3c909c004f202019f662bf7304ee59f6b5e4?dir=$1\"" >> .envrc
        direnv allow
      '';
    in
    {
      home.packages = [
        dvd
      ];
    };
}
