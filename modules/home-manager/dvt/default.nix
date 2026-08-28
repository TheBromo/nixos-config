{ ... }:
{
  flake.homeModules.dvt =
    { pkgs, ... }:
    let
      githash = "6a7eefd8fd910a831de525811393e499bc06dfa1";
      dvt = pkgs.writeShellScriptBin "dvt" ''
        if [ -z "$1" ]; then
          echo "no template specified"
          exit 1
        fi

        TEMPLATE=$1

        nix \
          --experimental-features 'nix-command flakes' \
          flake init \
          --template \
          "github:the-nix-way/dev-templates/${githash}#''${TEMPLATE}"

        direnv allow
      '';
    in
    {
      home.packages = [
        dvt
      ];
    };
}
