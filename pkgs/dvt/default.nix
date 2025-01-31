{pkgs, ...}: let
  githash = "959eff5d7eee92131e2bfcbe2bf86ab8c809974c";
in
  pkgs.writeScriptBin "dvt" ''
    #!${pkgs.bash}/bin/bash
    if [ -z $1 ]; then
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
  ''
