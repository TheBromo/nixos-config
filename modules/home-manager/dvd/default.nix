{ ... }:
{
  flake.homeModules.dvd =
    { pkgs, ... }:
    let
      dvd = pkgs.writeShellScriptBin "dvd" ''
        if [ -z "$1" ]; then
          echo "no template specified"
          exit 1
        fi

        echo "use flake \"github:the-nix-way/dev-templates/6a7eefd8fd910a831de525811393e499bc06dfa1?dir=$1\"" >> .envrc
        direnv allow
      '';
    in
    {
      home.packages = [
        dvd
      ];
    };
}
